package com.jeonbuk.report.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.annotation.PostConstruct;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

/**
 * Centralized API Key Manager using Singleton pattern for AI Analysis Server
 * Manages all external API keys securely
 */
@Component
@Slf4j
public class ApiKeyManager {

    private static ApiKeyManager instance;
    private final Map<String, String> apiKeys = new ConcurrentHashMap<>();

    // API Key property injections
    @Value("${app.openrouter.api.key:#{null}}")
    private String openRouterApiKey;

    @Value("${gemini.api.key:#{null}}")
    private String geminiApiKey;

    @Value("${app.roboflow.api-key:#{null}}")
    private String roboflowApiKey;

    @Value("${openai.api.key:#{null}}")
    private String openaiApiKey;

    @Value("${google.cloud.api.key:#{null}}")
    private String googleCloudApiKey;

    // Private constructor for singleton pattern
    private ApiKeyManager() {
        // Private constructor
    }

    @PostConstruct
    private void init() {
        instance = this;
        loadApiKeys();
        validateCriticalKeys();
    }

    /**
     * Get singleton instance
     * @return ApiKeyManager instance
     */
    public static ApiKeyManager getInstance() {
        if (instance == null) {
            throw new IllegalStateException("ApiKeyManager not initialized. Ensure Spring context is loaded.");
        }
        return instance;
    }

    /**
     * Load all API keys into the map
     */
    private void loadApiKeys() {
        setApiKey(ApiKeyType.OPENROUTER, openRouterApiKey);
        setApiKey(ApiKeyType.GEMINI, geminiApiKey);
        setApiKey(ApiKeyType.ROBOFLOW, roboflowApiKey);
        setApiKey(ApiKeyType.OPENAI, openaiApiKey);
        setApiKey(ApiKeyType.GOOGLE_CLOUD, googleCloudApiKey);

        log.info("API Keys loaded. Available keys: {}", 
                 apiKeys.keySet().stream()
                        .filter(key -> StringUtils.hasText(apiKeys.get(key)))
                        .toList());
    }

    /**
     * Set API key for a specific type
     */
    private void setApiKey(ApiKeyType type, String key) {
        if (StringUtils.hasText(key)) {
            apiKeys.put(type.getKey(), key);
            log.debug("API key loaded for: {}", type.getKey());
        } else {
            log.warn("API key not configured for: {}", type.getKey());
        }
    }

    /**
     * Get API key by type
     * @param type API key type
     * @return API key value
     * @throws IllegalArgumentException if key is not available
     */
    public String getApiKey(ApiKeyType type) {
        String key = apiKeys.get(type.getKey());
        if (!StringUtils.hasText(key)) {
            throw new IllegalArgumentException("API key not configured for: " + type.getKey());
        }
        return key;
    }

    /**
     * Get API key safely (returns null if not available)
     * @param type API key type
     * @return API key value or null
     */
    public String getApiKeySafe(ApiKeyType type) {
        return apiKeys.get(type.getKey());
    }

    /**
     * Check if API key is available
     * @param type API key type
     * @return true if available, false otherwise
     */
    public boolean hasApiKey(ApiKeyType type) {
        return StringUtils.hasText(apiKeys.get(type.getKey()));
    }

    /**
     * Get masked API key for logging (shows only first 4 and last 4 characters)
     * @param type API key type
     * @return masked API key
     */
    public String getMaskedApiKey(ApiKeyType type) {
        String key = apiKeys.get(type.getKey());
        if (!StringUtils.hasText(key)) {
            return "NOT_CONFIGURED";
        }
        if (key.length() <= 8) {
            return "****";
        }
        return key.substring(0, 4) + "****" + key.substring(key.length() - 4);
    }

    /**
     * Validate critical API keys
     */
    private void validateCriticalKeys() {
        for (ApiKeyType criticalKey : ApiKeyType.getCriticalKeys()) {
            if (!hasApiKey(criticalKey)) {
                log.warn("Critical API key missing: {}. Some features may not work properly.", 
                        criticalKey.getKey());
            }
        }
    }

    /**
     * Refresh API keys (useful for runtime configuration updates)
     */
    public void refreshApiKeys() {
        log.info("Refreshing API keys...");
        loadApiKeys();
        validateCriticalKeys();
    }

    /**
     * Get all available API key types
     * @return list of configured API key types
     */
    public java.util.List<String> getAvailableKeys() {
        return apiKeys.keySet().stream()
                     .filter(key -> StringUtils.hasText(apiKeys.get(key)))
                     .toList();
    }

    /**
     * API Key Types enumeration for AI Analysis Server
     */
    public enum ApiKeyType {
        OPENROUTER("openrouter", true),
        GEMINI("gemini", true),
        ROBOFLOW("roboflow", true),
        OPENAI("openai", false),
        GOOGLE_CLOUD("google-cloud", false);

        private final String key;
        private final boolean critical;

        ApiKeyType(String key, boolean critical) {
            this.key = key;
            this.critical = critical;
        }

        public String getKey() {
            return key;
        }

        public boolean isCritical() {
            return critical;
        }

        public static java.util.List<ApiKeyType> getCriticalKeys() {
            return java.util.Arrays.stream(values())
                                  .filter(ApiKeyType::isCritical)
                                  .toList();
        }
    }
}