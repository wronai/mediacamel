@Grab('org.apache.camel:camel-core:3.20.0')
@Grab('org.apache.camel:camel-file:3.20.0')
@Grab('org.apache.camel:camel-http:3.20.0')
@Grab('org.apache.camel:camel-jackson:3.20.0')
@Grab('org.apache.camel:camel-timer:3.20.0')
@Grab('com.github.lookfirst:sardine:5.10')
@Grab('org.slf4j:slf4j-simple:1.7.36')

import org.apache.camel.CamelContext
import org.apache.camel.builder.RouteBuilder
import org.apache.camel.impl.DefaultCamelContext
import org.apache.camel.Exchange
import com.github.sardine.Sardine
import com.github.sardine.SardineFactory
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Properties

class WebDAVCamelProcessor extends RouteBuilder {
    Properties props
    Sardine sardine

    WebDAVCamelProcessor() {
        props = new Properties()
        try {
            props.load(new FileInputStream("config/application.properties"))
        } catch (Exception e) {
            println "Warning: Could not load properties, using defaults"
            setDefaultProperties()
        }

        // Initialize WebDAV client (Sardine)
        sardine = SardineFactory.begin(
            props.getProperty("webdav.username", "webdav"),
            props.getProperty("webdav.password", "medavault123")
        )
    }

    void setDefaultProperties() {
        props.setProperty("webdav.url", "http://webdav-server/webdav")
        props.setProperty("webdav.username", "webdav")
        props.setProperty("webdav.password", "medavault123")
        props.setProperty("medavault.api.url", "http://medavault-backend:3000/api")
        props.setProperty("poll.interval", "10000")
        props.setProperty("processing.enabled", "true")
    }

    void configure() throws Exception {
        // Error handling
        errorHandler(deadLetterChannel("file:storage/failed")
            .maximumRedeliveries(3)
            .redeliveryDelay(5000)
            .retryAttemptedLogLevel(org.apache.camel.LoggingLevel.WARN))

        // Timer route to poll WebDAV server for new files
        from("timer:webdav-poll?period=" + props.getProperty("poll.interval"))
            .routeId("webdav-file-poller")
            .log("🔍 Polling WebDAV server for new files...")
            .process { Exchange exchange ->
                try {
                    String webdavUrl = props.getProperty("webdav.url")
                    def resources = sardine.list(webdavUrl)

                    for (resource in resources) {
                        if (!resource.isDirectory() && !resource.name.startsWith('.')) {
                            // Check if file was already processed
                            String fileName = resource.name
                            File processedMarker = new File("storage/processed/.${fileName}.processed")

                            if (!processedMarker.exists()) {
                                log.info("📁 Found new file: ${fileName}")
                                exchange.in.setHeader("WebDAVFileName", fileName)
                                exchange.in.setHeader("WebDAVUrl", webdavUrl + "/" + fileName)
                                exchange.in.setHeader("FileSize", resource.contentLength)
                                exchange.in.setHeader("LastModified", resource.modified)

                                // Download file from WebDAV
                                InputStream fileStream = sardine.get(webdavUrl + "/" + fileName)
                                exchange.in.setBody(fileStream)

                                // Process the file
                                exchange.setProperty("ProcessFile", true)
                                break // Process one file at a time
                            }
                        }
                    }
                } catch (Exception e) {
                    log.error("❌ Error polling WebDAV: ${e.message}")
                    exchange.setProperty("ProcessFile", false)
                }
            }
            .choice()
                .when(exchangeProperty("ProcessFile").isEqualTo(true))
                    .to("direct:process-webdav-file")
                .otherwise()
                    .log("ℹ️ No new files to process")
            .end()

        // Process downloaded file
        from("direct:process-webdav-file")
            .routeId("process-webdav-file")
            .log("🔄 Processing file: \${header.WebDAVFileName}")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                String fileExtension = getFileExtension(fileName)
                String fileType = categorizeFile(fileExtension)

                exchange.in.setHeader("FileType", fileType)
                exchange.in.setHeader("FileExtension", fileExtension)
                exchange.in.setHeader("ProcessingTimestamp", new Date().toString())

                // Save file locally first
                InputStream fileStream = exchange.in.getBody(InputStream.class)
                File localFile = new File("storage/incoming/${fileName}")
                Files.copy(fileStream, localFile.toPath())

                exchange.in.setBody(localFile)
                log.info("💾 File saved locally: ${localFile.absolutePath}")
            }
            .choice()
                .when(header("FileType").isEqualTo("image"))
                    .log("🖼️ Processing image file")
                    .to("direct:process-image")
                .when(header("FileType").isEqualTo("video"))
                    .log("🎥 Processing video file")
                    .to("direct:process-video")
                .when(header("FileType").isEqualTo("document"))
                    .log("📄 Processing document file")
                    .to("direct:process-document")
                .otherwise()
                    .log("📎 Processing generic file")
                    .to("direct:process-generic")
            .end()
            .to("direct:send-to-medavault")
            .to("direct:cleanup-webdav")

        // Image processing route
        from("direct:process-image")
            .routeId("process-image")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                File inputFile = exchange.in.getBody(File.class)

                // Simulate image processing (thumbnail generation, optimization)
                log.info("🎨 Generating thumbnails for: ${fileName}")

                // Create processed directory structure
                File processedDir = new File("storage/processed/images")
                processedDir.mkdirs()

                // Copy to processed location (in real scenario, apply transformations)
                File processedFile = new File(processedDir, fileName)
                Files.copy(inputFile.toPath(), processedFile.toPath())

                exchange.in.setHeader("ProcessedFilePath", processedFile.absolutePath)
                exchange.in.setHeader("ThumbnailGenerated", true)
                exchange.in.setBody(processedFile)
            }

        // Video processing route
        from("direct:process-video")
            .routeId("process-video")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                File inputFile = exchange.in.getBody(File.class)

                log.info("🎬 Processing video: ${fileName}")

                File processedDir = new File("storage/processed/videos")
                processedDir.mkdirs()

                File processedFile = new File(processedDir, fileName)
                Files.copy(inputFile.toPath(), processedFile.toPath())

                exchange.in.setHeader("ProcessedFilePath", processedFile.absolutePath)
                exchange.in.setHeader("VideoProcessed", true)
                exchange.in.setBody(processedFile)
            }

        // Document processing route
        from("direct:process-document")
            .routeId("process-document")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                File inputFile = exchange.in.getBody(File.class)

                log.info("📋 Processing document: ${fileName}")

                File processedDir = new File("storage/processed/documents")
                processedDir.mkdirs()

                File processedFile = new File(processedDir, fileName)
                Files.copy(inputFile.toPath(), processedFile.toPath())

                exchange.in.setHeader("ProcessedFilePath", processedFile.absolutePath)
                exchange.in.setHeader("DocumentProcessed", true)
                exchange.in.setBody(processedFile)
            }

        // Generic file processing
        from("direct:process-generic")
            .routeId("process-generic")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                File inputFile = exchange.in.getBody(File.class)

                log.info("📦 Processing generic file: ${fileName}")

                File processedDir = new File("storage/processed/generic")
                processedDir.mkdirs()

                File processedFile = new File(processedDir, fileName)
                Files.copy(inputFile.toPath(), processedFile.toPath())

                exchange.in.setHeader("ProcessedFilePath", processedFile.absolutePath)
                exchange.in.setBody(processedFile)
            }

        // Send to MedaVault
        from("direct:send-to-medavault")
            .routeId("send-to-medavault")
            .log("📤 Sending to MedaVault: \${header.WebDAVFileName}")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                String fileType = exchange.in.getHeader("FileType")
                String processedPath = exchange.in.getHeader("ProcessedFilePath")

                // Create metadata for MedaVault
                def metadata = [
                    filename: fileName,
                    fileType: fileType,
                    processedPath: processedPath,
                    source: "webdav",
                    timestamp: new Date().toString(),
                    size: exchange.in.getHeader("FileSize"),
                    lastModified: exchange.in.getHeader("LastModified")
                ]

                exchange.in.setHeader("Content-Type", "application/json")
                exchange.in.setBody(groovy.json.JsonOutput.toJson(metadata))

                log.info("📋 Metadata created for MedaVault: ${metadata}")
            }
            .to("http:" + props.getProperty("medavault.api.url") + "/media?httpMethod=POST")
            .log("✅ Successfully sent to MedaVault")

        // Cleanup WebDAV (optional - remove processed files)
        from("direct:cleanup-webdav")
            .routeId("cleanup-webdav")
            .process { Exchange exchange ->
                String fileName = exchange.in.getHeader("WebDAVFileName")
                String webdavUrl = exchange.in.getHeader("WebDAVUrl")

                // Mark as processed
                File processedMarker = new File("storage/processed/.${fileName}.processed")
                processedMarker.createNewFile()

                // Optionally delete from WebDAV (uncomment if needed)
                // sardine.delete(webdavUrl)
                // log.info("🗑️ Deleted from WebDAV: ${fileName}")

                log.info("✅ File processing completed: ${fileName}")
            }
    }

    String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.')
        return lastDot > 0 ? fileName.substring(lastDot + 1).toLowerCase() : ""
    }

    String categorizeFile(String extension) {
        def images = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "svg"]
        def videos = ["mp4", "avi", "mov", "wmv", "flv", "mkv", "webm", "m4v"]
        def documents = ["pdf", "doc", "docx", "txt", "rtf", "odt", "xls", "xlsx", "ppt", "pptx"]

        if (extension in images) return "image"
        if (extension in videos) return "video"
        if (extension in documents) return "document"
        return "generic"
    }
}

// Main execution
println "🚀 Starting WebDAV-Camel-MedaVault Integration..."
println "🌐 WebDAV Server: ${System.getenv('WEBDAV_URL') ?: 'http://webdav-server/webdav'}"
println "🎯 MedaVault API: ${System.getenv('MEDAVAULT_API') ?: 'http://medavault-backend:3000/api'}"

CamelContext context = new DefaultCamelContext()
context.addRoutes(new WebDAVCamelProcessor())

// Graceful shutdown
Runtime.runtime.addShutdownHook(new Thread() {
    void run() {
        println "\n🛑 Shutting down WebDAV-Camel integration..."
        context.stop()
    }
})

context.start()
println "✅ Integration started successfully!"

// Keep running
while (true) {
    Thread.sleep(10000)
    // Health check
    println "💓 System running - ${new Date()}"
}
