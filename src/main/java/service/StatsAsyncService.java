package service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.ConnectionPoolHelper;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class StatsAsyncService {

    public void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        final String sql =
            "SELECT " +
            " (SELECT COUNT(*) FROM POST)  AS POST_COUNT, " +
            " (SELECT COUNT(*) FROM USERS) AS USER_COUNT " +
            "FROM DUAL";

        try (Connection con = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            int postCount = 0, userCount = 0;
            if (rs.next()) {
                postCount = rs.getInt("POST_COUNT");
                userCount = rs.getInt("USER_COUNT");
            }

            resp.getWriter().write("{\"postCount\":" + postCount + ",\"userCount\":" + userCount + "}");
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    private static String esc(String s){
        if (s == null) return "error";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","");
    }
}
