package org.example.objects;

import org.example.Property;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.awscore.exception.AwsServiceException;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.nio.file.Paths;

public class CreateObjectBucket {

    static final String NAME_BUCKET = Property.getProperti("name.bucket");
    static final String PROFLE = Property.getProperti("profile");
    static final String NAME_OBJECT = Property.getProperti("name.object");
    static final String PATH_OBJECT = "arquivos/" + Property.getProperti("name.object");

    public static void main(String[] args) {

        final var regiao = Region.SA_EAST_1;

        final var s3 = S3Client.builder()
                .region(regiao)
                .credentialsProvider(ProfileCredentialsProvider.create(PROFLE))
                .build();

        saveFileBucket(s3);
        System.out.println("PutObject success ");
        s3.close();
    }

    private static void saveFileBucket(S3Client s3) {

        var file = Paths.get(PATH_OBJECT);

        final var putObjectRequest = PutObjectRequest.builder()
                .bucket(NAME_BUCKET)
                .key(file.getFileName().toString())
                .build();

        final var objetctExists =
                validarObjectExists(s3, NAME_OBJECT, file.getFileName().toString());

        if (!objetctExists) {
            s3.putObject(putObjectRequest, file);
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