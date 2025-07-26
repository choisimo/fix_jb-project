package com.jeonbuk.report.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

@Service
@RequiredArgsConstructor
@Slf4j
public class EncryptionService {

    @Value("${app.encryption.secret-key:JBReportPlatformDefaultSecretKey123}")
    private String secretKey;

    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES";

    public String encrypt(String plainText) {
        if (plainText == null) {
            return null;
        }
        
        try {
            SecretKeySpec keySpec = new SecretKeySpec(getKeyBytes(), ALGORITHM);
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec);
            
            byte[] encryptedBytes = cipher.doFinal(plainText.getBytes());
            return Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            log.error("암호화 실패", e);
            throw new RuntimeException("암호화에 실패했습니다", e);
        }
    }

    public String decrypt(String encryptedText) {
        if (encryptedText == null) {
            return null;
        }
        
        try {
            SecretKeySpec keySpec = new SecretKeySpec(getKeyBytes(), ALGORITHM);
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, keySpec);
            
            byte[] decodedBytes = Base64.getDecoder().decode(encryptedText);
            byte[] decryptedBytes = cipher.doFinal(decodedBytes);
            return new String(decryptedBytes);
        } catch (Exception e) {
            log.error("복호화 실패", e);
            throw new RuntimeException("복호화에 실패했습니다", e);
        }
    }

    private byte[] getKeyBytes() {
        // 32바이트 키로 패딩 또는 트림
        byte[] keyBytes = secretKey.getBytes();
        byte[] result = new byte[32]; // AES-256을 위한 32바이트
        
        if (keyBytes.length >= 32) {
            System.arraycopy(keyBytes, 0, result, 0, 32);
        } else {
            System.arraycopy(keyBytes, 0, result, 0, keyBytes.length);
            // 나머지는 0으로 패딩 (기본값)
        }
        
        return result;
    }
}