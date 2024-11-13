package org.example.buckets;

import org.example.Property;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.awscore.exception.AwsServiceException;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CreateBucketRequest;
import software.amazon.awssdk.services.s3.model.HeadBucketRequest;

public class CreateBucket {

    static final String NAME_BUCKET = Property.getProperti("name.bucket");
    static final String PROFLE = Property.getProperti("profile");

    public static void main(String[] args) {

        final var regiao = Region.SA_EAST_1;

        final var s3 = S3Client.builder()
                .region(regiao)
                .credentialsProvider(ProfileCredentialsProvider.create(PROFLE))
                .build();

        createBucket(s3);
        s3.close();
    }

    private static void createBucket(S3Client s3) {
        boolean bucketExists = validarBucketExists(s3);
        if (!bucketExists) {

            final var newBucket = CreateBucketRequest.builder()
                    .bucket(NAME_BUCKET)
                    .build();
            s3.createBucket(newBucket);

            final var s3Waiter = s3.waiter();
            final var waiterResponse = s3Waiter.waitUntilBucketExists(getHeadBucketRequest());
            waiterResponse.matched().response().ifPresent(System.out::println);
            System.out.println(NAME_BUCKET + " is ready");

        }
    }

    private static boolean validarBucketExists(S3Client s3) {
        try {
            var headBucket = getHeadBucketRequest();
            var headBucketResponse = s3.headBucket(headBucket);
            if (headBucketResponse.sdkHttpResponse().statusCode() == 200) {
                System.out.println("Bucket " + NAME_BUCKET + " já existe");
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