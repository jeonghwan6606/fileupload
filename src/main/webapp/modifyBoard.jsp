<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %>
<%@ page import = "com.oreilly.servlet.multipart.*" %>  
<%@ page import ="vo.*" %>  
<%@ page import ="java.io.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>    
<%
	//세션 유효성검사	
  
	if(session.getAttribute("loginMemberId")== null){
		response.sendRedirect(request.getContextPath() + "/login.jsp");
		return;
	}	

   
	
	System.out.println(request.getParameter("boardNo")+"<--boardNo");
	System.out.println(request.getParameter("boardFileNo")+"<--boardFileNo");
	
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));	 
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));	 

	Class.forName("org.mariadb.jdbc.Driver");  // board_file_no 확인하고 주석 지우기
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no =? and f.board_file_no=?";
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
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
	}	
	%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>board & boardFile 수정</h1>
	<form action="<%=request.getContextPath()%>/modifyBoardAction.jsp" method = "post" enctype="multipart/form-data">
			<input type ="hidden" name="boardNo" value=<%=m.get("boardNo")%> readonly="readonly">
			<input type ="hidden" name="boardFileNo" value=<%=m.get("boardFileNo")%> readonly="readonly">
			<table>
				<tr>
					<th>boardTitle</th>
					<td>
						<input type="text" name="boardTitle" value="<%=m.get("boardTitle")%>">
					</td>
				</tr>
				<tr>
					<th>boardFile(수정전 파일 : <%=m.get("originFilename")%>)</th>
					<td>
						<input type="file" name="boardFile">
					</td>
				</tr>	
			</table>
			<button type="submit">수정하기</button>
	</form>
</body>
</html>