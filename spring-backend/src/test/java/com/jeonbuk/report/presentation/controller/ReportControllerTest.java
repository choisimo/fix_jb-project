package com.jeonbuk.report.presentation.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jeonbuk.report.domain.entity.Report;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ReportControllerTest {
    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("Report CRUD API E2E")
    void report_crud_e2e() throws Exception {
        // 1. 생성
        Report report = new Report();
        report.setTitle("테스트 리포트");
        report.setContent("테스트 내용");
        // 필요한 필드 추가

        MvcResult createResult = mockMvc.perform(post("/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(report)))
                .andExpect(status().isCreated())
                .andReturn();
        String createJson = createResult.getResponse().getContentAsString();
        Report created = objectMapper.readValue(createJson, Report.class);
        assertThat(created.getId()).isNotNull();

        // 2. 단건 조회
        mockMvc.perform(get("/reports/" + created.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("테스트 리포트"));

        // 3. 전체 조회
        mockMvc.perform(get("/reports?page=0&size=10"))
                .andExpect(status().isOk());

        // 4. 수정
        created.setTitle("수정된 제목");
        mockMvc.perform(put("/reports/" + created.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(created)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("수정된 제목"));

        // 5. 삭제
        mockMvc.perform(delete("/reports/" + created.getId()))
                .andExpect(status().isNoContent());
    }
}
