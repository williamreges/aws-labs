package org.example.buckets;

import org.example.Property;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.awscore.exception.AwsServiceException;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteBucketRequest;
import software.amazon.awssdk.services.s3.model.HeadBucketRequest;

public class DeleteBucket {

    static final String NAME_BUCKET = Property.getProperti("name.bucket");
    static final String PROFLE = Property.getProperti("profile");

    public static void main(String[] args) {

        final var regiao = Region.SA_EAST_1;

        final var s3 = S3Client.builder()
                .region(regiao)
                .credentialsProvider(ProfileCredentialsProvider.create(PROFLE))
                .build();

        deleteBucket(s3);
        s3.close();
    }

    private static void deleteBucket(S3Client s3) {
        boolean bucketExists = validarBucketExists(s3);
        if (bucketExists) {
            final var bucket = DeleteBucketRequest.builder()
                    .bucket(NAME_BUCKET)
                    .build();
            s3.deleteBucket(bucket);
        }
    }

    private static boolean validarBucketExists(S3Client s3) {
        try {
            var headBucket = getHeadBucketRequest();

            var headBucketResponse = s3.headBucket(headBucket);
            if (headBucketResponse.sdkHttpResponse().statusCode() == 200) {
                System.out.println("Bucket " + NAME_BUCKET + " existe e pode ser deletado");
                return true;
            }

        } catch (AwsServiceException e) {
            System.out.println("Erro de S3" + e.getMessage());
        }
        return false;
    }

    private static HeadBucketRequest getHeadBucketRequest() {
        return HeadBucketRequest.builder()
                .bucket(NAME_BUCKET)
                .build();
    }
}