<%@page import="com.model.NewsVO"%>
<%@page import="com.dao.NewsDAO"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE HTML>
<!--
	Editorial by HTML5 UP
	html5up.net | @ajlkn
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
-->
<html>

<head>
    <title>Editorial by HTML5 UP</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />


    <style>

        form textarea{
            border-radius:0; 
            resize:none;
            color:black !important;
        }
        
        form div#reply{
            display:flex;
            margin-bottom:3%;
        }
        
        input[type='submit']:not(#register), input[type='button'] {border-radius:0;}
        
        ul.actions li {
            padding: 0 0 0 0.2em;
        }
        
        input#board_title{
            border-radius: 0;
            border: none;
            text-align: left;
            font-size: 1.75em;
            font-weight: 500;
            line-height: 1.5;
            letter-spacing: 0.1em;
            padding:0;
        }
        
        input[type='file']{
            display:none;
        }
        
        div.files{
            text-align:center;
            margin-right: 3%;
        }
        
        textarea {
            font-size: 1em;
                  font-weight: 600;
                  letter-spacing: 0.1em;
        }
    </style>

</head>

<body class="is-preload">
	<% 
    		int num = Integer.parseInt(request.getParameter("num"));
    		System.out.println("\n수정num값 : " + num);
    		NewsDAO dao = new NewsDAO();
    		NewsVO vo = dao.getOne(num);

     %>
    <!-- Wrapper -->
    <div id="wrapper">

        <!-- Main -->
        <div id="main">
            <div class="inner">

                <!-- Header -->
                <header id="header">
                    <a href="NewsList.jsp" class="logo"><strong>건강 뉴스 게시판</strong></a>
                </header>

                <!-- Banner -->
                <%-- <section id="banner">
                    <div class="content">
						<div id="page-wrapper">
							<!-- Wrapper -->
							<div class="wrapper">
								<div class="inner">
									<jsp:include page="/app/fix/header.jsp" />
								</div>
							</div> --%>

							<!-- Wrapper -->
							<div class="wrapper">
								<div class="inner">

                                    <section class="main">
                                        <div class="col-12">
                                            <ul class="actions" style="display:flex; justify-content:flex-end;">
                                                <li><input type="button" value="목록" class="primary" onclick="location.href='${pageContext.request.contextPath}/278board/NewsList.jsp'"/></li>
                                            </ul>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/NewsModifyCon.do?num=<%=num%>" name="writeForm" method="post" enctype="application/x-www-form-urlencoded">
                                            <header class="major">			
                                                <p>
                                                    <input id="boardTitle" name="boardTitle" type="text" value="<%=vo.getNews_title()%>">
                                                </p>
                                                <p style="text-align:left; margin-bottom:1%; margin-top:-1.75em; margin-left: 10px;">작성자 :<%=vo.getUser_id() %></p>
                                            </header>
                                            <hr style="margin-top:0;">
                                            
                                            <input type="hidden" name="userID" value="<%=vo.getUser_id()%>">
                                            <div class="con_text" style="margin-top:3%;">
                                                <textarea name="boardContent" placeholder="내용 작성" style="resize:none;" rows="20"><%=vo.getNews_content()%></textarea>
                                            </div>
                
                                            <ul class="actions" style="display:flex; justify-content:center; margin-top:3%;">
                                                <li><input type="button" value="수정" class="primary" onclick="send()"/></li>
                                                <li><input type="button" value="취소" onclick="history.back()"/></li>
                                            </ul>
                                        </form>
                                    </section>

								</div>
							</div>
						</div>
					</div>
				</section>

                <!-- Section -->


            </div>
        </div>



                    <!-- Section -->


                    <!-- Footer -->
                    <footer id="footer">
                        <p class="copyright">&copy; Untitled. All rights reserved. Demo Images: <a
                                href="https://unsplash.com">Unsplash</a>. Design: <a href="https://html5up.net">HTML5
                                UP</a>.</p>
                    </footer>

            </div>
        </div>

    </div>

    <!-- Scripts -->
    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/main.js"></script>
    <script>
        function send(){
            if(!$("input#boardTitle").val()){
                alert("제목을 작성해주세요.");
                return;
            }
            
            if(!$("textarea[name='boardContent']").val()){
                alert("내용을 작성해주세요.");
                return;
            }
            
            document.writeForm.submit();
        }
    </script>


</body>

</html>