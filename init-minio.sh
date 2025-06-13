#!/bin/sh
set -e

# Wait for MinIO to be ready
until (mc alias set minio http://minio:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD); do
  echo "Waiting for MinIO to be ready..."
  sleep 1
done

# Create the bucket if it doesn't exist
mc mb --ignore-existing minio/medavault

# Set bucket policy to public read (adjust as needed for your security requirements)
mc policy set download minio/medavault

# Create a service account for the application
mc admin user svcacct add \
  --access-key $S3_ACCESS_KEY_ID \
  --secret-key $S3_SECRET_ACCESS_KEY \
  minio $MINIO_ROOT_USER

# Set the policy for the service account
cat > /tmp/medavault-policy.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::medavault",
        "arn:aws:s3:::medavault/*"
      ]
    }
  ]
}
EOL

mc admin policy create minio medavault-policy /tmp/medavault-policy.json
mc admin policy attach minio medavault-policy --user=$S3_ACCESS_KEY_ID

echo "MinIO initialization complete"
