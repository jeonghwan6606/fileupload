<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!-- multipart 폼데이터를 처리하기 위해서 기본API(request)대신 외부 API(cos.jar)를 사용하겠다 -->
<!-- 기본API(request) 사용시 카드가 너무 복잡함 -->    
<%@ page import = "com.oreilly.servlet.*" %>
<%@ page import = "com.oreilly.servlet.multipart.*" %>

<%
	//원본 reqeust를 객체를 cos api로 랩핑
	//new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈 byte, 인코딩 등)
	
	//프로젝트안 upload폴더의 실제 물리적 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload"); //getRealPath() 메서드는 주어진 경로의 실제 파일 시스템 경로를 반환합니다.
	//ServletContext는 웹 애플리케이션의 정보를 담고 있는 객체로, 웹 애플리케이션 전체에서 공유되는 자원에 대한 액세스를 제공
	
	System.out.println(dir+"<--dir"); // commit 되기전 값이 저장되지만 war 파일로 만들면 위치가 고정된다.
	int maxFileSize = 1024*1024*100;
	
	// 하루 1000*60*60*24 
	
	DefaultFileRenamePolicy fp = new DefaultFileRenamePolicy();
	
	
	//MultipartRequest 클래스를 사용하여 원본 타입의 객체를 cos API로 래핑
	//MultipartRequest 생성자의 매개변수로는 원본 타입, 업로드 폴더 경로, 최대 파일 크기(byte), 인코딩 방식 등을 전달

	MultipartRequest mreq = new MultipartRequest(request, dir, maxFileSize,"UTF-8", fp);
%>
