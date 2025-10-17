package service.post;

import dao.PostDao;

/**
 * 게시글의 조회수(hit)를 1 증가시키는 서비스 클래스입니다.
 */
public class PostHitService {

    private final PostDao postDao = new PostDao();

    /**
     * 특정 게시글의 조회수를 증가시킵니다.
     * * @param postId 조회수를 증가시킬 게시글의 ID
     * @return 조회수 증가 성공 시 true, 실패 시 false
     */
    public boolean incrementPostHit(int postId) {
        // DAO의 updatePostHit 메서드를 호출하여 조회수를 증가시킵니다.
        // updatePostHit은 갱신된 행의 개수를 반환합니다 (성공 시 1, 실패 시 0).
        int affectedRows = postDao.updatePostHit(postId);
        
        return affectedRows > 0;
    }
}