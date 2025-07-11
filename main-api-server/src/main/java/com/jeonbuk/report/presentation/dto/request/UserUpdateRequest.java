package com.jeonbuk.report.presentation.dto.request;

import lombok.Data;

@Data
public class UserUpdateRequest {
    private String name;
    private String phone;
    private String address;
    private String department;
}