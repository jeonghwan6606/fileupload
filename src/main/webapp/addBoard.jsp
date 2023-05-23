<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%     
	if(session.getAttribute("loginMemberId")== null){
		response.sendRedirect(request.getContextPath() + "/login.jsp");
		return;
	}

	String memberId = (String)session.getAttribute("loginMemberId");
%>	
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>add board+file</title>
<style type ="text/css">
	table, th, td{
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<h1>자료 업로드</h1>
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" 
			method="post" 
			enctype="multipart/form-data">
		<table>
			<!-- 자료 업로드 제목글 -->
			<tr>
				<th>boardTitle</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea>	
				</td>
			</tr>
			
			<!-- memberId 표시영역 -->
			<tr>
				<th>memberId</th>
				<td>
					<input type="text" name="memberId" value="<%=memberId%>" readonly="readonly">	
				</td>
			</tr>
			<tr>
				<th>boardFile</th>
				<td>
					<input type="file" name="boardFile" multiple="multiple" required="required">	
				</td>
			</tr>
		</table>
		<button type="submit">파일업로드</button>
	</form>
</body>
</html>