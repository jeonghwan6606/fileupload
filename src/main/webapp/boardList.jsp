<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%
	/*
	SELECT 
		b.board_title boardTitle, 
		f.origin_filename originFilename, 
		f.save_filename saveFilename,
		path
	FROM board b INNER JOIN board_file f
	ON b.board_no = f.board_no
	ORDER BY b.createdate DESC
	*/
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		list.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style type="text/css">
	table, th, td {
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<div>
			<!-- 로그인 form-->
		<%
			if(session.getAttribute("loginMemberId")==null){
		%>
			<!-- 현재 웹 애플리케이션의 컨텍스트 경로(Context Path)를 문자열로 반환-->
			<!-- 웹 애플리케이션의 경로가 변경되어도 자동으로 업데이트되므로 유지보수에 용이-->
					
			<form action = "<%=request.getContextPath()%>/loginAction.jsp" method="post"> 				
			<div class="login_id">
            	<h4>ID</h4>
           		<input type="text" name="memberId">
           	</div>
            <div class="login_pw">
			                <h4>Password</h4>
			                <input type="password" name="memberPw"  placeholder="Password">
			            </div>
						<div class="submit">
               				 <input type="submit" value="로그인">
            			</div>	
					</form>	
		
				<% 	
					}else{
				%>
						<a  role="button" href="<%=request.getContextPath()%>/logoutAction.jsp">로그아웃</a>
						<a  role="button" href="<%=request.getContextPath()%>/addBoard.jsp">파일업로드</a>
				<%
					}
				%>
	</div>
	<h1>PDF 자료 목록</h1>
	<table>
		<tr>
			<td>boardTitle</td>
			<td>originFilename</td>
			<td>수정</td>
			<td>삭제</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(String)m.get("boardTitle")%></td>
					<td>
						<!-- a태그 다운로드 속성을 이용하면 참조주소를 다운로드 한다 -->
						<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
							<%=(String)m.get("originFilename")%>
						</a>
					</td>
					<% 
						if(session.getAttribute("loginMemberId")!=null){
					%>	
	
						<td>
							<a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a>
						</td>
						<td>
							<a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a>
						</td>
					<%
						}
					%>	
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>
