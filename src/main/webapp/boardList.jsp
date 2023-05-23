<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	//모델 1 페이징
	//전체 행수 구하는 쿼리
	int totalRow = 0;
	String totalRowSql = "select count(*) from board";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); //index 1사용
	}
	
	//쿼런트 페이지 가져오기
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	//rowperPage 및 시작행 끝나는 행 구하고 끝나는 행이 전체행보다 커지면(rowperPage를 더하고 1을 뻇을때) endrow는 totalrow와 같게
	int rowPerPage = 10;
	int beginRow = (currentPage-1)*rowPerPage+1;
	int endRow = beginRow + (rowPerPage-1);
	if(endRow> totalRow){
		endRow = totalRow;
	}
	
	//페이지 네비게이션 페이징 
	int pagePerPage = 10; //페이지마다 10쪽의 papagerPage
	int lastPage = totalRow / rowPerPage; // 마지막페이지는 전체행 수 나누기 페이지마다 행수 , 0으로 안나누어지면 +1 추가
	if(totalRow%rowPerPage != 0){
			lastPage = lastPage + 1;
	}
			
	//페이징 알고리즘에 따라 minPage 및 maxPage 정의 		
	int minPage = (((currentPage-1)/pagePerPage)*pagePerPage) +1; 
	int maxPage = minPage + (pagePerPage-1);
	if(maxPage > lastPage){ //마지막 페이지보다 maxPage가 클경우 라스트페이지와 같게 설정 (다음 버튼 생성 조건에 필요)
			maxPage = lastPage;
	}

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
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC Limit ?,?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,beginRow); // Limit 절에 대한 set
	stmt.setInt(2,rowPerPage);
	
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
	<div style="text-align:center;">
						<%
							if(minPage > 1){

						%>	
								<a  class="btn btn-outline-dark" href="<%=request.getContextPath()%>/boarList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>&nbsp;
						<% 	
									
								}
								
								for(int i = minPage; i<=maxPage; i=i+1){
									if(i== currentPage){
										%>
													<span  style= "background-color:yellow"><%=i%></span>
										<% 
									}else{
						%>	
										<a href= "<%=request.getContextPath()%>/boarList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
						<% 
									}
								}
								
								if(maxPage != lastPage){
						%>
									<a class="btn btn-outline-dark" href="<%=request.getContextPath()%>/boarList.jsp.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>&nbsp;
						<% 	
								}
						%>

					</div>
</body>
</html>
