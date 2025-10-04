<%@page import="java.sql.Connection"%>
<%@page import="utils.ConnectionPoolHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
      Connection conn =  ConnectionPoolHelper.getConnection();
%>
<%= conn.isClosed() %>
