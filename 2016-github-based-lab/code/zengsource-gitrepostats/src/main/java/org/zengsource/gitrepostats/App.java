/** 
 * 基于GitHub的实验教学代码。<br />
 * By 惠州学院 曾少宁
 */
package org.zengsource.gitrepostats;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.math.NumberUtils;
import org.zengsource.utils.JsonUtils;

/**
 * 统计一个Repo下贡献者的数据。
 */
public class App implements Api {
	public static void main(String[] args) {
		runAndRun();
	}

	public static void runAndRun() {
		try {
			System.out.println("Run at " + new Date());
			run();
		} catch (RuntimeException e) {
			e.printStackTrace();
			try {
				System.out.println("Sleep at " + new Date());
				Thread.sleep(61 * 60 * 1000);
				runAndRun(); // run again
			} catch (InterruptedException e1) {
				e1.printStackTrace();
			}
		}
	}

	@SuppressWarnings("unchecked")
	public static void run() {
		// 先登录

		// 读取贡献者 Contributors
		File file = new File("./");
		File jsonFile = new File(file.getAbsolutePath() + "/src/json/contributors.json");
		List<Map<String, Object>> contributors = new ArrayList<Map<String, Object>>();
		if (!jsonFile.exists()) { // 先取回所有的成员列表
			String url = CONTRIBUTORS + "?" + PER_PAGE + "100&" + PAGE + "?" + CLIENT_ID_SECRET;
			int total = 0;
			int pages = 1;
			String resp = Http.get(url + pages);
			if (resp == null) { // 限制到了，应该停一个小时
				throw new RuntimeException("Take a rest for one hour!");
			}
			while (resp != null && resp.startsWith("[")) {
				List<Map<String, Object>> list = JsonUtils.toList(resp);
				System.out.println(list.size());
				if (list.size() > 0) {
					total += list.size();
					contributors.addAll(list);
					resp = Http.get(url + ++pages);
				} else {
					break;
				}
				// for (Map<String, Object> contributor : contributors) {
				// System.out.println(contributor);
				// }
			}
			System.out.println(total);
			writeToFile(jsonFile, JsonUtils.toString(contributors));
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			contributors = JsonUtils.toList(json);
		}

		// 读取提交记录 Commits
		jsonFile = new File(file.getAbsolutePath() + "/src/json/commits.json");
		List<Map<String, Object>> commits = new ArrayList<Map<String, Object>>();
		if (!jsonFile.exists()) { // 从GitHub取数据
			String url = COMMITS + "?" + PER_PAGE + "100&" + PAGE + "?" + CLIENT_ID_SECRET;
			int total = 0;
			int pages = 1;
			String resp = Http.get(url + pages);
			if (resp == null) { // 限制到了，应该停一个小时
				throw new RuntimeException("Take a rest for one hour!");
			}
			while (resp != null && resp.startsWith("[")) {
				List<Map<String, Object>> list = JsonUtils.toList(resp);
				System.out.println(list.size());
				if (list.size() > 0) {
					total += list.size();
					commits.addAll(list);
					resp = Http.get(url + ++pages);
				} else {
					break;
				}
				// for (Map<String, Object> contributor : contributors) {
				// System.out.println(contributor);
				// }
			}
			System.out.println(total);
			writeToFile(jsonFile, JsonUtils.toString(commits));
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			commits = JsonUtils.toList(json.toString());
		}

		// 统计每一个的COMMITS
		Map<String, Stats> all = new HashMap<String, Stats>();
		int commitCount = 1;
		for (Map<String, Object> commit : commits) {
			String sha = commit.get("sha").toString();
			System.out.println((commitCount++) + " - " + sha);
			Map<String, Object> author = (Map<String, Object>) commit.get("author");
			// System.out.println(commit);
			// System.out.println(author);
			if (author == null) {
				author = (Map<String, Object>) commit.get("commit");
				author = (Map<String, Object>) author.get("author");
			}
			String login = author.get("login") != null ? //
					author.get("login").toString() : author.get("name").toString();
			Stats stats = all.get(login);
			if (stats == null) {
				stats = new Stats();
				all.put(login, stats);
			}
			stats.commits++;
			// 取回一条COMMIT的数据
			jsonFile = new File(file.getAbsolutePath() + "/src/json/commits/" + sha + ".json");
			Map<String, Object> oneCommit = null;
			if (!jsonFile.exists()) { // 从服务器取数据
				String url = COMMITS + "/" + sha + "?" + CLIENT_ID_SECRET;
				String resp = Http.get(url);
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				oneCommit = JsonUtils.toMap(resp);
				writeToFile(jsonFile, JsonUtils.toString(oneCommit));
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				oneCommit = JsonUtils.toMap(json);
			}
			//
			Map<String, Object> statsMap = (Map<String, Object>) oneCommit.get("stats");
			stats.additions += (Integer) statsMap.get("additions");
			stats.deletions += (Integer) statsMap.get("deletions");
			if (stats.number == null) { // 找学号
				List<Map<String, Object>> fileList = (List<Map<String, Object>>) oneCommit.get("files");
				for (Map<String, Object> map : fileList) {
					String filename = map.get("filename").toString();
					int pos = filename.indexOf("works/");
					if (pos > -1) {
						filename = filename.substring(pos + 6);
						pos = filename.indexOf("/");
						if (pos > -1) { // 找到学号
							stats.number = filename.substring(0, pos);
							break;
						}
					}
				}
			}
		}

		// 读取Pulls
		jsonFile = getJsonFile("pulls");
		List<Map<String, Object>> pulls = new ArrayList<Map<String, Object>>();
		if (jsonFile == null // 还没有文件；或者未读取完
				|| !jsonFile.getName().equals("pulls.json")) {
			int total = 0;
			// 检查分页数
			int pages = 1;
			if (jsonFile != null) { // 页数在文件名中
				// 格式为：pulls-{未读取页数}.json
				String filename = jsonFile.getName();
				String pageStr = filename.replace("pulls-", "");
				pageStr = filename.replace(".json", "");
				pages = NumberUtils.toInt(pageStr, 1);
				// 读取原有内容
				String json = readFileToString(jsonFile);
				if (json != null) {
					pulls = JsonUtils.toList(json);
				}
			}
			// 从GitHub取数据
			String url = PULLS + "?" + CLIENT_ID_SECRET + "&" + STATE_CLOSED + "&" + PER_PAGE + "100&" + PAGE;
			String resp = Http.get(url + pages);
			if (resp == null) { // 限制到了，应该停一个小时
				throw new RuntimeException("Take a rest for one hour!");
			}
			boolean end = false;
			while (resp != null && resp.startsWith("[")) {
				List<Map<String, Object>> list = JsonUtils.toList(resp);
				System.out.println("找到Pulls：" + list.size());
				if (list.size() > 0) {
					total += list.size();
					pulls.addAll(list);
					resp = Http.get(url + ++pages);
				} else {
					end = true;
					break;
				}
			}
			System.out.println("Pulls总数：" + total);
			// 修改文件名
			String filename = "pulls-" + pages + ".json";
			if (end) {
				filename = "pulls.json";
			}
			File newFile = new File(file.getAbsolutePath() //
					+ "/src/json/" + filename); // 新文件
			if (jsonFile == null) {
				jsonFile = newFile;
			} else if (!filename.equals(jsonFile.getName())) {
				jsonFile.renameTo(newFile);
			}
			if (pulls.size() > 0) {
				writeToFile(jsonFile, JsonUtils.toString(pulls));
			}
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			pulls = JsonUtils.toList(json);
		}
		// 读取每一条Pull的内容
		System.out.println(pulls.size());
		List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
		for (Map<String, Object> pull : pulls) {
			Map<String, Object> map = null;
			int number = (Integer) pull.get("number");
			// 检查文件
			jsonFile = new File(file, "/src/json/pulls/" + number + ".json");
			if (!jsonFile.exists()) { // 不存在，从GitHub抓取
				String url = PULLS + "/" + number + "?" + CLIENT_ID_SECRET;
				String resp = Http.get(url);
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				map = JsonUtils.toMap(resp);
				writeToFile(jsonFile, JsonUtils.toString(map));
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				map = JsonUtils.toMap(json);
			}
			// 身份标识
			Map<String, Object> userMap = (Map<String, Object>) map.get("user");
			String login = (String) userMap.get("login");
			// 统计
			boolean merged = map.get("merged") != null ? (Boolean) map.get("merged") : false;
			boolean mergeable = map.get("mergeable") != null ? (Boolean) map.get("mergeable") : false;
			int comments = (Integer) map.get("comments");
			int review_comments = (Integer) map.get("review_comments");
			int commitss = (Integer) map.get("commits");
			int additions = (Integer) map.get("additions");
			int deletions = (Integer) map.get("deletions");
			int changed_files = (Integer) map.get("changed_files");
			Stats stats = all.get(login);
			if (stats == null) {
				stats = new Stats();
				all.put(login, stats);
			}
			stats.pulls += 1;
			stats.comments += comments;
			stats.changed_files += changed_files;
			// 格式
			// {
			// "login":"name",
			// "pulls": [{
			// "merged": true,
			// "others": '',
			// "commits": [{
			// }]
			// }]}
			Map<String, Object> stuMap = null;
			for (Map<String, Object> map2 : result) {
				String key = (String) map2.get("login");
				if (key.equals(login)) {
					stuMap = map2; // 已有
				}
			}
			if (stuMap == null) {
				stuMap = new HashMap<String, Object>();
				stuMap.put("login", login);
				result.add(stuMap);
			}
			List<Map<String, Object>> pullList = //
			(List<Map<String, Object>>) stuMap.get("pulls");
			if (pullList == null) {
				pullList = new ArrayList<Map<String, Object>>();
				stuMap.put("pulls", pullList);
			}
			Map<String, Object> pullMap = new HashMap<String, Object>();
			pullMap.put("number", number);
			pullMap.put("title", map.get("title"));
			pullMap.put("url", map.get("url"));
			pullMap.put("merged", merged);
			pullMap.put("mergeable", mergeable);
			pullMap.put("created_at", map.get("created_at"));
			// 取回评论信息
			pullMap.put("commentCount", comments);
			if (comments > 0) {
				System.out.println("Comments = " + comments);
				// 先检查文件
				jsonFile = new File(file, "/src/json/comments/" + number + ".json");
				List<Map<String, Object>> commentsOfPull = null;
				if (!jsonFile.exists()) {
					String url = (String) map.get("comments_url") + "?" + CLIENT_ID_SECRET;
					String resp = Http.get(url);
					if (resp == null) { // 限制到了，应该停一个小时
						throw new RuntimeException("Take a rest for one hour!");
					}
					commentsOfPull = JsonUtils.toList(resp);
					// if (commentsOfPull != null && commentsOfPull.size() > 0)
					// {
					writeToFile(jsonFile, JsonUtils.toString(commentsOfPull));
					// }
				} else { // 直接读取文件
					String json = readFileToString(jsonFile);
					commentsOfPull = JsonUtils.toList(json);
				}
				if (commentsOfPull != null) {
					List<Map<String, Object>> commentList //
					= new ArrayList<Map<String, Object>>();
					for (Map<String, Object> map3 : commentsOfPull) {
						Map<String, Object> commentMap = new HashMap<String, Object>();
						// 评论的用户
						commentMap.put("login", ((Map<String, Object>) map3.get("user")).get("login"));
						// 评论内容
						commentMap.put("body", map3.get("body"));
						commentMap.put("created_at", map3.get("created_at"));
						commentMap.put("updated_at", map3.get("updated_at"));
						commentList.add(commentMap);
					}
					pullMap.put("comments", commentList);
				}
				// 保存评论内容
			}
			pullMap.put("review_comments", review_comments);
			pullMap.put("additions", additions);
			pullMap.put("deletions", deletions);
			pullMap.put("changed_files", changed_files);
			// 取回Commits信息
			pullMap.put("commitCount", commitss);
			if (commitss > 0) {
				List<Map<String, Object>> commitList //
				= new ArrayList<Map<String, Object>>();
				// 先检查文件
				List<Map<String, Object>> list = null;
				jsonFile = new File(file, "/src/json/pulls/" + number + "_commits.json");
				if (!jsonFile.exists()) {
					String url = PULLS + "/" + number + "/commits" + "?" + CLIENT_ID_SECRET;
					String resp = Http.get(url);
					if (resp == null) { // 限制到了，应该停一个小时
						throw new RuntimeException("Take a rest for one hour!");
					}
					list = JsonUtils.toList(resp);
					writeToFile(jsonFile, JsonUtils.toString(list));
				} else { // 直接读取文件
					String json = readFileToString(jsonFile);
					list = JsonUtils.toList(json);
				}
				for (Map<String, Object> map2 : list) {
					String sha = (String) map2.get("sha");
					Map<String, Object> dataMap = null;
					jsonFile = new File(file, "/src/json/commits/" + sha + ".json");
					if (!jsonFile.exists()) {
						String url = COMMITS + "/" + sha + "?" + CLIENT_ID_SECRET;
						String resp = Http.get(url);
						if (resp == null) { // 限制到了，应该停一个小时
							throw new RuntimeException("Take a rest for one hour!");
						}
						dataMap = JsonUtils.toMap(resp);
						writeToFile(jsonFile, JsonUtils.toString(dataMap));
					} else { // 直接读取文件
						String json = readFileToString(jsonFile);
						dataMap = JsonUtils.toMap(json);
					}
					// 保存统计数据
					Map<String, Object> commitMap = new HashMap<String, Object>();
					commitMap.put("sha", sha);
					commitMap.put("url", dataMap.get("url"));
					Map<String, Object> statsMap = (Map<String, Object>) dataMap.get("stats");
					commitMap.put("additions", statsMap.get("additions"));
					commitMap.put("deletions", statsMap.get("deletions"));
					List<Object> files = (List<Object>) dataMap.get("files");
					commitMap.put("changed_files", files != null ? files.size() : 0);
					// 评论数
					int commentCount = (Integer) ((Map<String, Object>) dataMap.get("commit")).get("comment_count");
					commitMap.put("commentCount", commentCount);
					if (commentCount > 0) {
						jsonFile = new File(file, "/src/json/comments/" + sha + ".json");
						List<Map<String, Object>> commentsOfCommit = null;
						if (!jsonFile.exists()) {
							String url = (String) dataMap.get("comments_url") + "?" + CLIENT_ID_SECRET;
							String resp = Http.get(url);
							if (resp == null) { // 限制到了，应该停一个小时
								throw new RuntimeException("Take a rest for one hour!");
							}
							commentsOfCommit = JsonUtils.toList(resp);
							// if (commentsOfCommit != null &&
							// commentsOfCommit.size() > 0) {
							writeToFile(jsonFile, JsonUtils.toString(commentsOfCommit));
							// }
						} else { // 直接读取文件
							String json = readFileToString(jsonFile);
							commentsOfCommit = JsonUtils.toList(json);
						}
						if (commentsOfCommit != null && commentsOfCommit.size() > 0) {
							List<Map<String, Object>> commentList //
							= new ArrayList<Map<String, Object>>();
							for (Map<String, Object> map3 : commentsOfCommit) {
								Map<String, Object> commentMap = new HashMap<String, Object>();
								// 评论的用户
								commentMap.put("login", ((Map<String, Object>) map3.get("user")).get("login"));
								// 评论内容
								commentMap.put("body", map3.get("body"));
								commentMap.put("created_at", map3.get("created_at"));
								commentMap.put("updated_at", map3.get("updated_at"));
								commentList.add(commentMap);
							}
							commitMap.put("comments", commentList);
						}
					}
					commitList.add(commitMap);
				}
				pullMap.put("commits", commitList);
			}
			pullList.add(pullMap);
		}

		// 取回Issue列表
		jsonFile = getJsonFile("issues");
		List<Map<String, Object>> issues = new ArrayList<Map<String, Object>>();
		if (jsonFile == null // 还没有文件；或者未读取完
				|| !jsonFile.getName().equals("issues.json")) {
			int total = 0;
			// 检查分页数
			int pages = 1;
			if (jsonFile != null) { // 页数在文件名中
				// 格式为：issues-{未读取页数}.json
				String filename = jsonFile.getName();
				String pageStr = filename.replace("issues-", "");
				pageStr = filename.replace(".json", "");
				pages = NumberUtils.toInt(pageStr, 1);
				// 读取原有内容
				String json = readFileToString(jsonFile);
				if (json != null) {
					issues = JsonUtils.toList(json);
				}
			}
			// 从GitHub取数据
			String url = ISSUES + "?" + CLIENT_ID_SECRET + "&" + PER_PAGE + "100&" + PAGE;
			String resp = Http.get(url + pages);
			if (resp == null) { // 限制到了，应该停一个小时
				throw new RuntimeException("Take a rest for one hour!");
			}
			boolean end = false;
			while (resp != null && resp.startsWith("[")) {
				List<Map<String, Object>> list = JsonUtils.toList(resp);
				System.out.println("取到Issues数：" + list.size());
				if (list.size() > 0) {
					total += list.size();
					issues.addAll(list);
					resp = Http.get(url + ++pages);
				} else {
					end = true;
					break;
				}
			}
			System.out.println("Issues总数：" + total);
			// 修改文件名
			String filename = "issues-" + pages + ".json";
			if (end) {
				filename = "issues.json";
			}
			File newFile = new File(file.getAbsolutePath() //
					+ "/src/json/" + filename); // 新文件
			if (jsonFile == null) {
				jsonFile = newFile;
			} else if (!filename.equals(jsonFile.getName())) {
				jsonFile.renameTo(newFile);
			}
			if (pulls.size() > 0) {
				writeToFile(jsonFile, JsonUtils.toString(pulls));
			}
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			issues = JsonUtils.toList(json);
		}
		// 读取每一条Issue的内容
		System.out.println(issues.size());
		for (Map<String, Object> issue : issues) {
			Map<String, Object> map = null;
			int number = (Integer) issue.get("number");
			// 有可能是Pull
			jsonFile = new File(file, "/src/json/pulls/" + number + ".json");
			if (jsonFile.exists()) {
				continue; // 是Pull，跳过。
			}
			// 检查文件
			jsonFile = new File(file, "/src/json/issues/" + number + ".json");
			if (!jsonFile.exists()) { // 不存在，从GitHub抓取
				String url = ISSUES + "/" + number + "?" + CLIENT_ID_SECRET;
				String resp = Http.get(url);
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				map = JsonUtils.toMap(resp);
				// 判断是不是Issue html_url
				String htmlUrl = (String) map.get("html_url");
				if (htmlUrl.contains("/issues/")) { // 是
					writeToFile(jsonFile, JsonUtils.toString(map));
				}
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				map = JsonUtils.toMap(json);
			}
			// 检查事件文件
			File eventsFile = new File(file, "/src/json/issues/" + number + "_events.json");
			List<Map<String, Object>> events = new ArrayList<Map<String, Object>>();
			if (!eventsFile.exists()) { // 文件不存在，先去GitHub查询
				String url = (String) map.get("events_url");
				String resp = url != null ? Http.get(url + "?" + CLIENT_ID_SECRET) : null;
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				events = JsonUtils.toList(resp);
				writeToFile(eventsFile, JsonUtils.toString(events));
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				events = JsonUtils.toList(json);
			}
		}

		// 将结果保存为JSON
		jsonFile = new File(file, "/src/json/result.json");
		writeToFile(jsonFile, JsonUtils.toString(result));

		// 打印统计列表
		System.out.println(
				"Login\t\t\t\tNumber\t\t\tPulls\t\tCommits\t\tAdditions\tDeletions\tChanged Files\tComments\tReview Comments");
		for (String key : all.keySet()) {
			Stats stats = all.get(key);
			String showKey = key;
			// System.out.print(key);
			if (key.length() >= 24) {
				showKey = key.length() >= 28 ? key.substring(0, 24) + "... " : key;
				showKey += "\t";
			} else if (key.length() >= 8) {
				showKey += "\t\t\t";
			} else {
				showKey += "\t\t\t\t";
			}
			System.out.print(showKey);
			System.out.print(stats.number + "\t\t");
			System.out.print(stats.pulls + "\t\t");
			System.out.print(stats.commits + "\t\t");
			System.out.print(stats.additions + "\t\t");
			System.out.print(stats.deletions + "\t\t");
			System.out.print(stats.changed_files + "\t\t");
			System.out.print(stats.comments + "\t\t");
			System.out.print(stats.review_comments + "\t");
			System.out.println();
		}
		System.out.println("学生人数：" + all.keySet().size());

	}

	private static File getJsonFile(final String prefix) {
		File root = new File("./");
		File dir = new File(root.getAbsolutePath(), "/src/json/");
		File[] files = dir.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				File file = new File(dir, name);
				return file.isFile() && name.startsWith(prefix) && name.endsWith(".json");
			}
		});
		return files != null && files.length > 0 ? files[0] : null;
	}

	private static String readFileToString(File jsonFile) {
		try {
			System.out.println("Read from " + jsonFile.getAbsolutePath());
			BufferedReader reader = new BufferedReader( //
					new FileReader(jsonFile));
			StringBuilder json = new StringBuilder();
			String line = reader.readLine();
			while (line != null) {
				json.append(line + "\n");
				line = reader.readLine();
			}
			reader.close();
			return json.toString();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	private static void writeToFile(File jsonFile, String json) {
		try { // 保存到文件
			System.out.println("Write to " + jsonFile.getAbsolutePath());
			FileWriter fileWriter = new FileWriter(jsonFile);
			fileWriter.write(json);
			fileWriter.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}

class Stats {
	String number;
	String login;
	int additions;
	int deletions;
	int pulls;
	int commits;
	int changed_files;
	int comments;
	int review_comments;
}
