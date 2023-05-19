<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %>
<%@ page import = "com.oreilly.servlet.multipart.*" %>  
<%@ page import ="vo.*" %>  
<%@ page import ="java.io.*" %>
<%
	
	//프로젝트안 upload폴더의 실제 물리적 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload"); //getRealPath() 메서드는 주어진 경로의 실제 파일 시스템 경로를 반환합니다.
	//ServletContext는 웹 애플리케이션의 정보를 담고 있는 객체로, 웹 애플리케이션 전체에서 공유되는 자원에 대한 액세스를 제공
	
	System.out.println(dir+"<--dir"); // commit 되기전 값이 저장되지만 war 파일로 만들면 위치가 고정된다.
	int maxFileSize = 1024*1024*10;
	
	DefaultFileRenamePolicy fp = new DefaultFileRenamePolicy(); //rename cos API
	
	
	//MultipartRequest 클래스를 사용하여 원본 타입의 객체를 cos API로 래핑
	//MultipartRequest 생성자의 매개변수로는 원본 타입, 업로드 폴더 경로, 최대 파일 크기(byte), 인코딩 방식 등을 전달

	MultipartRequest mRequest = new MultipartRequest(request, dir, maxFileSize,"utf-8", fp);
	
	//업로드 파일이 PDF파일이 아니면
	 if(mRequest.getContentType("boardFile").equals("application/pdf")==false){
		 //이미 upload폴더에 저장된 파일을 삭제
		 System.out.println("PDF파일이 아닙니다");
		 String saveFilename = mRequest.getFilesystemName("boardFile"); //저장된 파일네임 가져오기
		 File f = new File(dir+"/"+saveFilename); //파일 객체 f 를 가져온 파일명으로 지정 / = new File("d:/abc/uploadsign.파일명")
		 //역슬러쉬가 window 기본 포맷
		 if(f.exists()){
			 f.delete();
			 System.out.println(saveFilename+"파일삭제");
		 }
		 return;
	 }
	
	//1. MultipartRequest 로 받아온 text값(input type="text") 변환
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	
	System.out.println(boardTitle+"<--boardTitle");
	System.out.println(memberId+"<--memberId");
	

	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	

	//2. MultipartRequest 로 받아온 text값(input type="file") 변환 API(원본파일이름, 저장된파일이름, 컨텐츠타입)
	//<--파일(바이너리)은 이미 MultipartRequest객체생성시(reqeust랩핑시, 9라인) 먼저 저장
	String type = mRequest.getContentType("boardFile");
	String originFilename =mRequest.getOriginalFileName("boardFile"); //boardFile 테이블 저장용
	String saveFilename = mRequest.getFilesystemName("boardFile");
	
	

	System.out.println(type+"<--type");
	System.out.println(originFilename+"<--originFilename");
	System.out.println(saveFilename+"<--saveFilename");
	
	// vo에 가져온 값들 넣어주기
	BoardFile boardFile = new BoardFile();
	//boardFile.setBoardNo(boardNo)
	
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
%>