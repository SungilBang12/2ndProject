package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet("/saveUserSession")
public class SaveUserSessionServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // JSON 데이터 읽기
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            
            // JSON 파싱
            JsonObject jsonObject = JsonParser.parseString(sb.toString()).getAsJsonObject();
            String uid = jsonObject.get("uid").getAsString();
            String email = jsonObject.get("email").getAsString();
            
            // 세션에 저장
            HttpSession session = request.getSession();
            session.setAttribute("userUid", uid);
            session.setAttribute("userEmail", email);
            session.setAttribute("isLoggedIn", true);
            
            // 성공 응답
            JsonObject responseJson = new JsonObject();
            responseJson.addProperty("success", true);
            responseJson.addProperty("message", "세션 저장 완료");
            
            response.getWriter().write(responseJson.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("success", false);
            errorJson.addProperty("message", "세션 저장 실패");
            
            response.getWriter().write(errorJson.toString());
        }
    }
}