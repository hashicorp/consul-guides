package com.hashicorp.lance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ConsulMutualTlsApplication {

	public static void main(String[] args) {
		SpringApplication.run(ConsulMutualTlsApplication.class, args);
	}
}
