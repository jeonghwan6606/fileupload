<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %>
<%@ page import = "com.oreilly.servlet.multipart.*" %>  
<%@ page import ="vo.*" %>  
<%@ page import ="java.io.*" %>
<%@ page import = "java.sql.*" %>
<%
	
	//프로젝트안 upload폴더의 실제 물리적 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload"); //getRealPath() 메서드는 주어진 경로의 실제 파일 시스템 경로를 반환합니다.

	System.out.println(dir+"<--dir"); // commit 되기전 값이 저장되지만 war 파일로 만들면 위치가 고정된다.
	int maxFileSize = 1024*1024*10;
	
	DefaultFileRenamePolicy fp = new DefaultFileRenamePolicy(); //rename cos API
	
	
	//MultipartRequest 클래스를 사용하여 원본 타입의 객체를 cos API로 래핑
	//MultipartRequest 생성자의 매개변수로는 원본 타입, 업로드 폴더 경로, 최대 파일 크기(byte), 인코딩 방식 등을 전달

	MultipartRequest mRequest = new MultipartRequest(request, dir, maxFileSize,"utf-8", fp);
	System.out.println(mRequest.getOriginalFileName("boardFile")+"<--boardFileName");
	
	

	// 유효성 검사
	System.out.println(mRequest.getParameter("memberId")+"<--removeBoardForm 에서 가져온 memberId");
	System.out.println((String)session.getAttribute("loginMemberId")+"<--sessionloginId");
	System.out.println(mRequest.getParameter("memberIdCk")+"<--removeBoardForm 에서 가져온 memberIdCk");
	

	//1. 요청분석
	String loginMemberId = (String)session.getAttribute("loginMemberId");
	//remove form에서 가져온 board작성 memeberId와 삭제확인용 멤버아이디 
	String memberId = mRequest.getParameter("memberId");
	String memberIdCk = mRequest.getParameter("memberIdCk");
	
	System.out.println(loginMemberId+"<--loginMemberId");
	System.out.println(memberId+"<--memberId");
	System.out.println(memberIdCk+"<--memberIdCk");
	
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));//랩핑된 보드넘버 가져오기
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String boardTitle = mRequest.getParameter("boardTitle");
	
	//memberIdCk가 공백이가 자체가 null일경우
	if(memberIdCk== null
			||memberIdCk.equals("")
			){
		response.sendRedirect(request.getContextPath() + "/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);
		return;
	}	
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	
	//1-1 memberid 체크 분기 및  해당 boardtable(행) 삭제 쿼리
	if(!memberIdCk.equals(loginMemberId)){ //로그인 세션 아이디와 확인용 memberIdCk가 일치하지 않으면 리다이렉트
		response.sendRedirect(request.getContextPath() + "/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);	
		System.out.println("<--로그인아이디 와 memeberIdCk 불일치");
		return;	
	}else{
	
		BoardFile boardFile = new BoardFile();
		boardFile.setBoardFileNo(boardFileNo); //check

		String removeFileSql = "select save_filename from board_file WHERE board_file_no= ?";
		PreparedStatement removeFileStmt = conn.prepareStatement(removeFileSql);
		removeFileStmt.setInt(1,boardFile.getBoardFileNo());
		ResultSet removeFileRs = removeFileStmt.executeQuery();
		String saveFilename = "";
		if(removeFileRs.next()){
			saveFilename = removeFileRs.getString("save_filename");
			System.out.println(saveFilename+"<-- removeFileRs.getString(파일네임)");
		}
		File f = new File(dir+"/"+saveFilename);
		if(f.exists()){
			f.delete();
			System.out.println(saveFilename+"기존파일삭제");
		}
		
		String removeBoardSql = "Delete from board Where board_no =? and member_id =?";
		PreparedStatement removeStmt = conn.prepareStatement(removeBoardSql);
		removeStmt.setInt(1, boardNo);
		removeStmt.setString(2, memberIdCk); // memberId
		int removeRow = removeStmt.executeUpdate(); 
		 
		if(removeRow == 1){
	
				//1-2board file 삭제 모델
				response.sendRedirect(request.getContextPath()+"/boardList.jsp");
				return;
		}else{
			//게시물 작성자인 board테이블의 memberId와 일치 하지 않는경우 리다이렉트
			response.sendRedirect(request.getContextPath() + "/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);
			System.out.println("기존파일삭제 실패");
		}	
	}
%>    
