<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
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
						<a  role="button" href="<%=request.getContextPath()%>/boardList.jsp">파일관리</a>
				<%
					}
				%>
	</div>
</body>
</html>