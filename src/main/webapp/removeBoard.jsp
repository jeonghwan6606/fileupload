<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %>
<%@ page import = "com.oreilly.servlet.multipart.*" %>  
<%@ page import ="vo.*" %>  
<%@ page import ="java.io.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>    
<%
	//세션 유효성 검사
	if(session.getAttribute("loginMemberId")== null){
		response.sendRedirect(request.getContextPath() + "/login.jsp");
		return;
	}	

	String loginMemberId = (String)session.getAttribute("loginMemberId");
	
	//요청값 유효성 검사 및 변환

	System.out.println(request.getParameter("boardNo")+"<--boardNo");
	System.out.println(request.getParameter("boardFileNo")+"<--boardFileNo");
	
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));	 
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));	 

	Class.forName("org.mariadb.jdbc.Driver");  // board_file_no 확인하고 주석 지우기
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	String sql = "SELECT b.board_no boardNo, b.member_id memberId, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no =? and f.board_file_no=?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,boardNo);
	stmt.setInt(2,boardFileNo);
	ResultSet rs = stmt.executeQuery();
	
	System.out.println(stmt+"<--stmt");

	HashMap<String, Object> m = null ;
	if(rs.next()) {
	    m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("memberId", rs.getString("memberId"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
	}	
	
	System.out.println(m.get("memberId"));
	%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>board & boardFile 삭제</h1>
	<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method = "post" enctype="multipart/form-data">
			<input type ="hidden" name="boardNo" value=<%=m.get("boardNo")%> readonly="readonly">
			<input type ="hidden" name="boardFileNo" value=<%=m.get("boardFileNo")%> readonly="readonly">
			board member_Id<input type ="text" name="memberId" value=<%=m.get("memberId")%> readonly="readonly">
			<table>
				<tr>
					<th>boardTitle</th>
					<td>
						<input type="text" name="boardTitle" value="<%=m.get("boardTitle")%>" readonly="readonly">
					</td>
				</tr>
				<tr>
					<th colspan="2">boardFile(수정전 파일 : <%=m.get("originFilename")%>)</th>
				</tr>	
				<tr>
					<th>memberIdCk
					<td>
						<input type="text" name="memberIdCk" required="required">
					</td>
				</tr>
			</table>
			<button type="submit">삭제하기</button>
	</form>
</body>
</html>