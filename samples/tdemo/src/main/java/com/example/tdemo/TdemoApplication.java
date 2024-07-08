package com.example.tdemo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class TdemoApplication {

	@Value("${CF_INSTANCE_GUID}")
	private String cfInstanceGuid;

	@Value("${CF_INSTANCE_INDEX}")
	private String cfInstanceIndex;


	public static void main(String[] args) {
		SpringApplication.run(TdemoApplication.class, args);
	}

	@RequestMapping("/")
	public String index() {
		String s = "hello tanzu: index: " + cfInstanceIndex + " guid: " + cfInstanceGuid + "\n";
		System.out.println(s);
		return s;
	}
}
