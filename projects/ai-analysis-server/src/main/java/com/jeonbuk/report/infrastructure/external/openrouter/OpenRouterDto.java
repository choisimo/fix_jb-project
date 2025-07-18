package com.jeonbuk.report.infrastructure.external.openrouter;

import lombok.Data;

/**
 * OpenRouter API 요청/응답 DTO 클래스들
 */
public class OpenRouterDto {

    @Data
    public static class ChatCompletionRequest {
        private String model;
        private java.util.List<Message> messages;
        private Double temperature = 0.7;
        private Integer maxTokens = 1000;
        private Boolean stream = false;
    }

    @Data
    public static class Message {
        private String role; // "system", "user", "assistant"
        private Object content; // String for text, List<MessageContent> for multimodal

        public Message() {
        }

        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }

        public Message(String role, java.util.List<MessageContent> content) {
            this.role = role;
            this.content = content;
        }

        public String getContent() {
            if (content instanceof String) {
                return (String) content;
            } else if (content instanceof java.util.List) {
                // Extract text content from multimodal message
                java.util.List<MessageContent> contentList = (java.util.List<MessageContent>) content;
                return contentList.stream()
                        .filter(c -> "text".equals(c.getType()))
                        .map(MessageContent::getText)
                        .findFirst()
                        .orElse("");
            }
            return null;
        }

        public static Message system(String content) {
            return new Message("system", content);
        }

        public static Message user(String content) {
            return new Message("user", content);
        }

        public static Message userWithImage(String text, String imageUrl) {
            java.util.List<MessageContent> content = java.util.Arrays.asList(
                    new MessageContent("text", text),
                    new MessageContent("image_url", new ImageUrl(imageUrl))
            );
            return new Message("user", content);
        }

        public static Message assistant(String content) {
            return new Message("assistant", content);
        }
    }

    @Data
    public static class MessageContent {
        private String type; // "text" or "image_url"
        private String text; // for text type
        private ImageUrl imageUrl; // for image_url type

        public MessageContent() {
        }

        public MessageContent(String type, String text) {
            this.type = type;
            this.text = text;
        }

        public MessageContent(String type, ImageUrl imageUrl) {
            this.type = type;
            this.imageUrl = imageUrl;
        }
    }

    @Data
    public static class ImageUrl {
        private String url;
        private String detail = "auto"; // "low", "high", "auto"

        public ImageUrl() {
        }

        public ImageUrl(String url) {
            this.url = url;
        }

        public ImageUrl(String url, String detail) {
            this.url = url;
            this.detail = detail;
        }
    }

    @Data
    public static class ChatCompletionResponse {
        private String id;
        private String object;
        private Long created;
        private String model;
        private java.util.List<Choice> choices;
        private Usage usage;
    }

    // 별칭 - 기존 코드 호환성을 위해
    public static class ChatResponse extends ChatCompletionResponse {
    }

    // 추가 별칭들
    public static class ChatMessage extends Message {
        public ChatMessage() {
            super();
        }

        public ChatMessage(String role, String content) {
            super(role, content);
        }
    }

    public static class ChatRequest extends ChatCompletionRequest {
    }

    @Data
    public static class Choice {
        private Integer index;
        private Message message;
        private String finishReason;
    }

    @Data
    public static class Usage {
        private Integer promptTokens;
        private Integer completionTokens;
        private Integer totalTokens;
    }

    @Data
    public static class ErrorResponse {
        private Error error;
    }

    @Data
    public static class Error {
        private String message;
        private String type;
        private String param;
        private String code;
    }
}
