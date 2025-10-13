package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import utils.ConnectionPoolHelper;

public class BoardDao {

    // 우선순위 1: DB에서 찾기(있을 때)
    // 우선순위 2: 기본값 반환(없을 때)
    public int getListIdBySlugOrName(String slugOrName, int defaultListId){
        String sql =
            "SELECT list_id FROM board_list " +
            "WHERE LOWER(slug) = LOWER(?) OR LOWER(name) = LOWER(?)";
        try (Connection c = ConnectionPoolHelper.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, slugOrName);
            ps.setString(2, slugOrName);
            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception ignore) { }
        return defaultListId; // fallback
    }

    // 노을(sunset) 기본 listId(예: 21). 실제 값과 다르면 여기만 바꿔도 됩니다.
    public int getSunsetListId(){
        return getListIdBySlugOrName("sunset", 21);
    }
}
