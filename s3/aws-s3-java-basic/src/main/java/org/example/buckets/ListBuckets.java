package org.example.buckets;

import org.example.Property;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.Bucket;
import software.amazon.awssdk.utils.CollectionUtils;

import java.util.List;

public class ListBuckets {

    static final String PROFLE = Property.getProperti("profile");

    public static void main(String[] args) {

        final var regiao = Region.SA_EAST_1;

        final var s3 = S3Client.builder()
                .region(regiao)
                .credentialsProvider(ProfileCredentialsProvider.create(PROFLE))
                .build();

        listBuckets(s3);
        s3.close();
    }

    private static void listBuckets(S3Client s3) {

        List<Bucket> buckets =
                s3.listBuckets()
                        .buckets();

        if (!CollectionUtils.isNullOrEmpty(buckets)) {
            System.out.println("Existe " + buckets.stream().count() + " Buckets na conta");

            buckets.stream()
                    .forEach(System.out::println);
        }

    }

}