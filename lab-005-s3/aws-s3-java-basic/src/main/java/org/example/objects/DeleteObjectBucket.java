package org.example.objects;

import org.example.Property;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.awscore.exception.AwsServiceException;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;

import java.nio.file.Paths;

public class DeleteObjectBucket {

    static final String NAME_BUCKET = Property.getProperti("name.bucket");
    static final String PROFLE = Property.getProperti("profile");
    static final String NAME_OBJECT = Property.getProperti("name.object");

    public static void main(String[] args) {

        final var regiao = Region.SA_EAST_1;

        final var s3 = S3Client.builder()
                .region(regiao)
                .credentialsProvider(ProfileCredentialsProvider.create(PROFLE))
                .build();

        deleteObjectBucket(s3);
        System.out.println("DeleteObject success ");
        s3.close();
    }

    private static void deleteObjectBucket(S3Client s3) {


        final var putObjectRequest = DeleteObjectRequest.builder()
                .bucket(NAME_BUCKET)
                .key(NAME_OBJECT)
                .build();

        final var objetctExists =
                validarObjectExists(s3, NAME_BUCKET, NAME_OBJECT);

        if (objetctExists) {
            s3.deleteObject(putObjectRequest);
        }

    }

    private static boolean validarObjectExists(S3Client s3, String nameBucket, String nameObject) {
        try {
            var headBucket = getHeadObjectRequest(nameBucket, nameObject);
            var headBucketResponse = s3.headObject(headBucket);
            if (headBucketResponse.sdkHttpResponse().statusCode() == 200) {
                System.out.println("Objeto " + nameBucket + " já existe");
                return true;
            }

        } catch (AwsServiceException e) {
            System.out.println("Erro de S3" + e.getMessage());
        }
        return false;
    }

    private static HeadObjectRequest getHeadObjectRequest(String nameBucket, String nameObject) {
        return HeadObjectRequest.builder()
                .bucket(nameBucket)
                .key(nameObject)
                .build();
    }
}