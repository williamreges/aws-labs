package org.example.objects;

import org.example.Property;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ListObjectsRequest;

public class ListObjectsBucket {

    static final Logger log = LoggerFactory.getLogger(ListObjectsBucket.class);
    static final String NAME_BUCKET = Property.getProperti("name.bucket");
    static final String PROFLE = Property.getProperti("profile");

    public static void main(String[] args) {

        final var regiao = Region.SA_EAST_1;

        final var s3 = S3Client.builder()
                .region(regiao)
                .credentialsProvider(ProfileCredentialsProvider.create(PROFLE))
                .build();

        log.info("=== ListObjects===");
        findObjectBucket(s3);
        s3.close();
    }

    private static void findObjectBucket(S3Client s3) {
        var listObjectsRequest =
                ListObjectsRequest.builder().bucket(NAME_BUCKET)
                        .build();

        s3.listObjects(listObjectsRequest)
                .contents()
                .forEach(s3Object -> System.out.println(s3Object.key()));

    }

}