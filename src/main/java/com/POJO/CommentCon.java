package com.POJO;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.command.Command;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.model.UserVO;

public class CommentCon implements Command{

	@Override
	public String execute(HttpServletRequest request, HttpServletResponse response) throws IOException {
		request.setCharacterEncoding("UTF-8");
		// TODO Auto-generated method stub
		StringBuffer sb = new StringBuffer(); // ?½?΄?¨ ?°?΄?° ???₯
		String line = null; // λ²νΌ?? ?°?΄?° ?½?? ?¬?©(?????₯)

		BufferedReader reader = request.getReader(); // ?μ²??°?΄?° ?½?? ?¬?©
		while ((line = reader.readLine()) != null) { // ?½? ?°?΄?°κ°? ??? λ°λ³΅ ??
			sb.append(line); // ?½?΄?¨?°?΄?°λ₯? sb(stringbuffer) ? μΆκ?
		}

		JsonParser parser = new JsonParser(); // ??±(λ¬Έμ?΄ -> JSON)
		JsonElement element = parser.parse(sb.toString()); // λ²νΌ?°?΄?° λ¬Έμ?΄λ‘? λ³?κ²½ν JSON?Όλ‘? λ³?κ²?

		int boardnum = element.getAsJsonObject().get("boardnum").getAsInt(); // ?€κ°μ΄ boardnum?Έ ?°?΄?°
		String reply = element.getAsJsonObject().get("reply").getAsString(); // ?€κ°μ΄ reply?Έ ?°?΄?°

		System.out.println("λ²νΈ : " + boardnum);
		System.out.println("?κΈ? : " + reply);

		HttpSession session = request.getSession();
		UserVO vo = (UserVO)session.getAttribute("loginVO");
		
		// λ‘κ·Έ?Έ κ°??₯?  κ²½μ° μ½μμ°½μ : λ‘κ·Έ?Έ?±κ³? μΆλ ₯ (??΄μ§??΄?X)
		// λ‘κ·Έ?Έ λΆκ??₯?  κ²½μ° μ½μμ°½μ : λ‘κ·Έ?Έ?€?¨ μΆλ ₯ (??΄μ§??΄?X)
		Connection conn = null;
		PreparedStatement psmt = null;

		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
			String url = "jdbc:oracle:thin:@project-db-stu.ddns.net:1524:xe";
			String dbid = "campus_d_1_0216";
			String dbpw = "smhrd1";

			conn = DriverManager.getConnection(url, dbid, dbpw);

			String sql = "insert into T_COMMENT values(T_COMMENT_SEQ.nextval, ?, ?, sysdate, ?, 0)";
			psmt = conn.prepareStatement(sql);
			psmt.setInt(1, boardnum);
			psmt.setString(2, reply);
			psmt.setString(3, vo.getUser_id());

			int cnt = psmt.executeUpdate();

			PrintWriter out = response.getWriter();

			if (cnt > 0) {
				// "success" ??΅
				out.print("success");
			} else {
				// "fail" ??΅
				out.print("fail");
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				psmt.close();
				conn.close();
			} catch (Exception e2) {
				e2.printStackTrace();
			}
		}// end of finally
		String pass="";
		
		return pass;
		
	}

}
