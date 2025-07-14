package com.jeonbuk.report.domain.entity;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class UserRoleConverter implements AttributeConverter<User.UserRole, String> {

    @Override
    public String convertToDatabaseColumn(User.UserRole userRole) {
        if (userRole == null) {
            return null;
        }
        return userRole.name().toLowerCase();
    }

    @Override
    public User.UserRole convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.trim().length() == 0) {
            return null;
        }
        return User.UserRole.valueOf(dbData.toUpperCase());
    }
}