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

	//1) board_title 수정
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));//랩핑된 보드넘버 가져오기
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String boardTitle = mRequest.getParameter("boardTitle");
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	String boardSql = "UPDATE board Set board_title = ? Where board_no =?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boarRow = boardStmt.executeUpdate(); 
	
	
	//2) 
	if(mRequest.getOriginalFileName("boardFile") != null){
		String originFilename = mRequest.getOriginalFileName("boardFile");
		//수정할 파일이 있고
		//pdf 파일 유효성 검사, 아니면 새로 업로드 한 파일을 삭제
		 
		
		if(mRequest.getContentType("boardFile").equals("application/pdf")==false){
			System.out.println("PDF파일이 아닙니다");
			 String saveFilename = mRequest.getFilesystemName("boardFile"); //저장된 파일네임 가져오기
			 File f = new File(dir+"/"+saveFilename); //파일 객체 f 를 가져온 파일명으로 지정 / = new File("d:/abc/uploadsign.파일명")
			 //역슬러쉬가 window 기본 포맷
			 if(f.exists()){
				 f.delete();
				 System.out.println(saveFilename+"새파일삭제");
			 }
		}else{
			//pdf파일인지 먼저 확인후 맞다면 이전파일 삭제, db수정(update)
			String type = mRequest.getContentType("boardFile");
			originFilename =mRequest.getOriginalFileName("boardFile"); //boardFile 테이블 저장용
			String saveFilename = mRequest.getFilesystemName("boardFile");
			
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo); //check
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			 System.out.println(saveFilename+"새파일삭제");
			
			//2-2) 이전파일 삭제 
			String saveFilenameSql = "Select save_filename from board_file WHERE board_file_no =?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1,boardFile.getBoardFileNo());
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			String prePath = null;
			String preSaveFilename = "";
			if(saveFilenameRs.next()){
				preSaveFilename = saveFilenameRs.getString("save_filename");

			}
			File f = new File(dir+"/"+preSaveFilename);
			if(f.exists()){
				f.delete();
				System.out.println(preSaveFilename+"이전파일삭제");
			}
			//2-3)수정된 파일의 정보로 db를 수정
			String boardFileSql = "UPDATE board_file SET origin_filename=?, save_filename=? WHERE board_file_no=?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			
			System.out.println(boardFileStmt+"boardFileStmt");
			int boardFileRow = boardFileStmt.executeUpdate();
		}
	}
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");	
%>    
