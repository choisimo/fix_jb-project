package com.jeonbuk.report.application.service;

import com.jeonbuk.report.domain.entity.Report;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class GisService {
    
    // Jeonbuk province boundaries (approximate)
    private static final double JEONBUK_MIN_LAT = 35.0;
    private static final double JEONBUK_MAX_LAT = 36.3;
    private static final double JEONBUK_MIN_LNG = 126.2;
    private static final double JEONBUK_MAX_LNG = 127.9;
    
    // City/District boundaries for Jeonbuk (simplified administrative divisions)
    private final Map<String, CityBounds> cityBounds = new HashMap<>();
    
    public GisService() {
        initializeCityBounds();
    }
    
    private void initializeCityBounds() {
        // Jeonju (전주시)
        cityBounds.put("JEONJU", new CityBounds(35.780, 35.880, 127.080, 127.180, "JEONJU_CITY"));
        
        // Gunsan (군산시)
        cityBounds.put("GUNSAN", new CityBounds(35.940, 36.020, 126.680, 126.780, "GUNSAN_CITY"));
        
        // Iksan (익산시)
        cityBounds.put("IKSAN", new CityBounds(35.920, 36.000, 126.940, 127.040, "IKSAN_CITY"));
        
        // Jeollabuk-do (전북 기타 지역)
        cityBounds.put("NAMWON", new CityBounds(35.380, 35.480, 127.370, 127.470, "NAMWON_CITY"));
        cityBounds.put("KIMJE", new CityBounds(35.760, 35.860, 126.860, 126.960, "KIMJE_CITY"));
        cityBounds.put("JEONGEUP", new CityBounds(35.540, 35.640, 126.840, 126.940, "JEONGEUP_CITY"));
        
        // Counties (군 지역)
        cityBounds.put("WANJU", new CityBounds(35.820, 35.920, 127.120, 127.220, "WANJU_COUNTY"));
        cityBounds.put("GOCHANG", new CityBounds(35.400, 35.500, 126.680, 126.780, "GOCHANG_COUNTY"));
        cityBounds.put("BUAN", new CityBounds(35.680, 35.780, 126.680, 126.780, "BUAN_COUNTY"));
    }
    
    public void processLocation(Report report) {
        log.info("Processing GIS location for report: {}", report.getId());
        
        if (report.getLatitude() == null || report.getLongitude() == null) {
            log.warn("Report {} has no location data", report.getId());
            return;
        }
        
        double lat = report.getLatitude().doubleValue();
        double lng = report.getLongitude().doubleValue();
        
        // Validate coordinates are within Jeonbuk province
        if (!isWithinJeonbuk(lat, lng)) {
            log.warn("Report {} location ({}, {}) is outside Jeonbuk province", 
                    report.getId(), lat, lng);
            report.setAssignedDepartment("EXTERNAL_REGION");
            return;
        }
        
        // Determine administrative division
        String administrativeDivision = determineAdministrativeDivision(lat, lng);
        String workspace = determineWorkspace(lat, lng);
        String department = determineDepartment(administrativeDivision, workspace);
        
        // Update report with GIS analysis results
        report.setAssignedDepartment(department);
        report.setWorkspaceId(workspace);
        
        log.info("GIS processing complete for report {}: division={}, workspace={}, department={}", 
                report.getId(), administrativeDivision, workspace, department);
    }
    
    public String determineWorkspace(Double latitude, Double longitude) {
        if (latitude == null || longitude == null) {
            log.warn("Invalid coordinates provided: lat={}, lng={}", latitude, longitude);
            return "integrated-detection";
        }
        
        double lat = latitude;
        double lng = longitude;
        
        // Check if within Jeonbuk province
        if (!isWithinJeonbuk(lat, lng)) {
            log.info("Location ({}, {}) is outside Jeonbuk province", lat, lng);
            return "external-region";
        }
        
        // Determine city/county
        String city = determineAdministrativeDivision(lat, lng);
        
        // Map to workspace based on administrative division
        return switch (city) {
            case "JEONJU_CITY" -> "jeonbuk-jeonju";
            case "GUNSAN_CITY" -> "jeonbuk-gunsan";
            case "IKSAN_CITY" -> "jeonbuk-iksan";
            case "NAMWON_CITY", "KIMJE_CITY", "JEONGEUP_CITY" -> "jeonbuk-cities";
            case "WANJU_COUNTY", "GOCHANG_COUNTY", "BUAN_COUNTY" -> "jeonbuk-counties";
            default -> "jeonbuk-general";
        };
    }
    
    private boolean isWithinJeonbuk(double lat, double lng) {
        return lat >= JEONBUK_MIN_LAT && lat <= JEONBUK_MAX_LAT &&
               lng >= JEONBUK_MIN_LNG && lng <= JEONBUK_MAX_LNG;
    }
    
    private String determineAdministrativeDivision(double lat, double lng) {
        for (Map.Entry<String, CityBounds> entry : cityBounds.entrySet()) {
            CityBounds bounds = entry.getValue();
            if (lat >= bounds.minLat && lat <= bounds.maxLat &&
                lng >= bounds.minLng && lng <= bounds.maxLng) {
                return bounds.administrativeCode;
            }
        }
        
        // If not found in specific city boundaries, determine by general area
        if (lat >= 35.750 && lat <= 35.900 && lng >= 127.050 && lng <= 127.200) {
            return "JEONJU_AREA"; // Jeonju metropolitan area
        } else if (lat >= 35.900 && lng <= 126.800) {
            return "WESTERN_JEONBUK"; // Western coastal area
        } else if (lat <= 35.500) {
            return "SOUTHERN_JEONBUK"; // Southern mountainous area
        } else {
            return "CENTRAL_JEONBUK"; // Central plain area
        }
    }
    
    private String determineDepartment(String administrativeDivision, String workspace) {
        // Map administrative division to responsible department
        return switch (administrativeDivision) {
            case "JEONJU_CITY", "JEONJU_AREA" -> "JEONJU_CITY_HALL";
            case "GUNSAN_CITY" -> "GUNSAN_CITY_HALL";
            case "IKSAN_CITY" -> "IKSAN_CITY_HALL";
            case "NAMWON_CITY" -> "NAMWON_CITY_HALL";
            case "KIMJE_CITY" -> "KIMJE_CITY_HALL";
            case "JEONGEUP_CITY" -> "JEONGEUP_CITY_HALL";
            case "WANJU_COUNTY" -> "WANJU_COUNTY_OFFICE";
            case "GOCHANG_COUNTY" -> "GOCHANG_COUNTY_OFFICE";
            case "BUAN_COUNTY" -> "BUAN_COUNTY_OFFICE";
            case "WESTERN_JEONBUK" -> "WESTERN_REGIONAL_OFFICE";
            case "SOUTHERN_JEONBUK" -> "SOUTHERN_REGIONAL_OFFICE";
            case "CENTRAL_JEONBUK" -> "CENTRAL_REGIONAL_OFFICE";
            default -> "JEONBUK_PROVINCIAL_OFFICE";
        };
    }
    
    /**
     * Calculate distance between two points using Haversine formula
     */
    public double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
        final double R = 6371; // Earth's radius in kilometers
        
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c; // Distance in kilometers
    }
    
    /**
     * Find nearest administrative office
     */
    public String findNearestOffice(double lat, double lng) {
        double minDistance = Double.MAX_VALUE;
        String nearestOffice = "JEONBUK_PROVINCIAL_OFFICE";
        
        // Predefined office locations (approximate coordinates)
        Map<String, double[]> officeLocations = Map.of(
            "JEONJU_CITY_HALL", new double[]{35.8242, 127.1479},
            "GUNSAN_CITY_HALL", new double[]{35.9675, 126.7374},
            "IKSAN_CITY_HALL", new double[]{35.9483, 126.9578},
            "JEONBUK_PROVINCIAL_OFFICE", new double[]{35.8203, 127.1088}
        );
        
        for (Map.Entry<String, double[]> entry : officeLocations.entrySet()) {
            double[] coords = entry.getValue();
            double distance = calculateDistance(lat, lng, coords[0], coords[1]);
            
            if (distance < minDistance) {
                minDistance = distance;
                nearestOffice = entry.getKey();
            }
        }
        
        log.debug("Nearest office to ({}, {}) is {} at distance {} km", 
                lat, lng, nearestOffice, minDistance);
        
        return nearestOffice;
    }
    
    private static class CityBounds {
        final double minLat, maxLat, minLng, maxLng;
        final String administrativeCode;
        
        CityBounds(double minLat, double maxLat, double minLng, double maxLng, String administrativeCode) {
            this.minLat = minLat;
            this.maxLat = maxLat;
            this.minLng = minLng;
            this.maxLng = maxLng;
            this.administrativeCode = administrativeCode;
        }
    }
}