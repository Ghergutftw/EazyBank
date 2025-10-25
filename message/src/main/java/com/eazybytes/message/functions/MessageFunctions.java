package com.eazybytes.message.functions;

import com.eazybytes.message.dto.AccountsMsgDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Supplier;

@Configuration
public class MessageFunctions {

    private static final Logger log = LoggerFactory.getLogger(MessageFunctions.class);

    @Bean
    public Function<AccountsMsgDto,AccountsMsgDto> email() {
        return accountsMsgDto -> {
            log.info("Sending email with the details : " +  accountsMsgDto.toString());
            return accountsMsgDto;
        };
    }

    @Bean
    public Function<AccountsMsgDto,Long> sms() {
        return accountsMsgDto -> {
            log.info("Sending sms with the details : " +  accountsMsgDto.toString());
            return accountsMsgDto.accountNumber();
        };
    }

    @Bean
    public Supplier<Map<String, String>> websiteHealth() {
        return () -> Map.of(
                "google", check("https://www.google.com"),
                "github", check("https://www.github.com"),
                "spring", check("https://spring.io")
        );
    }

    private String check(String siteUrl) {
        try {
            URL url = new URL(siteUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("HEAD");
            connection.setConnectTimeout(3000);
            connection.connect();

            int responseCode = connection.getResponseCode();
            if (responseCode == 200) {
                return "✅ UP (" + responseCode + ")";
            } else {
                return "⚠️ Responded with status " + responseCode;
            }
        } catch (Exception e) {
            return "❌ DOWN (" + e.getMessage() + ")";
        }
    }

}
