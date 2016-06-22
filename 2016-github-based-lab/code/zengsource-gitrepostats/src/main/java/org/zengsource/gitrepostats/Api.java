/**
 * 基于GitHub的实验教学代码。<br />
 * By 惠州学院 曾少宁
 */
package org.zengsource.gitrepostats;

/**
 * GitHub Api路径。
 * 
 * @author zengsn
 * @since 8.0
 */
public interface Api {
	public static final String HTTPS = "https://";
	public static final String GIT = "api.github.com";
	public static final String LOGIN = "https://api.github.com/user";
	public static final String REPO = "/repos";
	public static final String ORG = "/hzuapps";
	public static final String PROJ = "/angular-erp-ui";
	//public static final String PROJ = "/android-labs";

	public static final String USERNAME = "zengsn";
	public static final String TOKEN = "88602906f4b5b5676495cf41929723d9228b2e6a";

	// 在GitHub上创建的个人应用ID，使用ID拉取数据限制访问量较高
	public static final String CLIENT_ID = "client_id=";
	public static final String CLIENT_SECRET = "client_secret=";
	public static final String CLIENT_ID_SECRET = CLIENT_ID + "&" + CLIENT_SECRET;

	public static final String CONTRIBUTORS = HTTPS //
			// + USERNAME + ":" //
			// + TOKEN + ":x-oauth-basic@" //
			+ GIT + REPO + ORG + PROJ + "/contributors";
	public static final String COMMITS = HTTPS //
			// + USERNAME + ":" //
			// + TOKEN + ":x-oauth-basic@" //
			+ GIT + REPO + ORG + PROJ + "/commits";
	/** /repos/:owner/:repo/pulls */
	public static final String PULLS = HTTPS //
			+ GIT + REPO + ORG + PROJ + "/pulls";
	/** /repos/:owner/:repo/issues */
	public static final String ISSUES = HTTPS //
			+ GIT + REPO + ORG + PROJ + "/issues";
	public static final String STATE = "state=";
	public static final String STATE_CLOSED = STATE + "closed";

	public static final String PER_PAGE = "per_page=";
	public static final String PAGE = "page=";
}
