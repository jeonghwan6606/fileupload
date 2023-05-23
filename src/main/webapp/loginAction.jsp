<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>    
<%
	//세션 유효성 검사 -> 요청값 유효성 검사
	if(session.getAttribute("loginMemberId")!=null){
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}
	

	//요청값 유효성 검사
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw);
	
	//디버깅
	
	
	String dburl="jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser="root";
	String dbpw = "java1234";
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = null;
	PreparedStatement stmt = null ;
	ResultSet rs = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	String sql = "SELECT member_id memberId FROM member WHERE member_id = ? and member_pw = PASSWORD(?)";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1,paramMember.getMemberId());
	stmt.setString(2,paramMember.getMemberPw());
	System.out.println(stmt+"<--loginAction stmt");
	rs =stmt.executeQuery();
	if(rs.next()){
		// 세션에 로그인 정보(여기서는 memberId) 저장
		session.setAttribute("loginMemberId",rs.getString("memberId"));
		System.out.println("로그인 성공 세션정보 :"+session.getAttribute("loginMemberId"));
	}else{
		System.out.println("로그인 실패");
	}
	
	response.sendRedirect(request.getContextPath()+"/login.jsp");
	
%>