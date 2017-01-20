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
		// 所有贡献者的数据
		Map<String, Stats> allData = new HashMap<String, Stats>();
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
			}
			System.out.println(total);
			writeToFile(jsonFile, JsonUtils.toString(contributors));
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			contributors = JsonUtils.toList(json);
		}
		// 取出贡献者帐号
		for (Map<String, Object> contributorMap : contributors) {
			String login = getString(contributorMap, "login");
			Stats stats = allData.get(login);
			if (stats == null) {
				stats = new Stats();
				stats.login = login;
				allData.put(login, stats);
				System.out.println("新用户：" + login);
			}
		}

		// 读取提交记录 Commits
		jsonFile = new File(file.getAbsolutePath() + "/src/json/commits.json");
		List<Map<String, Object>> commitList = new ArrayList<Map<String, Object>>();
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
				System.out.println("取到Commit数：" + list.size());
				if (list.size() > 0) {
					total += list.size();
					commitList.addAll(list);
					resp = Http.get(url + ++pages);
				} else {
					break;
				}
			}
			System.out.println("Commit总数：" + total);
			writeToFile(jsonFile, JsonUtils.toString(commitList));
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			commitList = JsonUtils.toList(json.toString());
		}

		// 抓取COMMITS
		int commitCount = 1;
		for (Map<String, Object> commitMap : commitList) {
			String sha = getString(commitMap, "sha");
			System.out.println("Commit:" + (commitCount++) + " - " + sha);
			Map<String, Object> authorMap = getMap(commitMap, "author");
			// System.out.println(commit);
			// System.out.println(author);
			if (authorMap == null) {
				authorMap = getMap(commitMap, "commit.author");
				// author = (Map<String, Object>) commit.get("commit");
				// author = (Map<String, Object>) author.get("author");
			}
			String login = getString(authorMap, "login");
			if (login == null) {
				login = getString(authorMap, "name");
			}
			if (Api.LOGIN_TEACHER.equals(login)) {
				continue; // 忽略老师提交的代码
			}
			Stats stats = allData.get(login);
			if (stats == null) { // 可能没有提交过？
				stats = new Stats();
				stats.login = login;
				allData.put(login, stats);
				System.out.println("新用户：" + login);
			}
			// 取回一条COMMIT的数据
			jsonFile = new File(file.getAbsolutePath() + "/src/json/commits/" + sha + ".json");
			Map<String, Object> oneCommitMap = null;
			if (!jsonFile.exists()) { // 从服务器取数据
				String url = COMMITS + "/" + sha + "?" + CLIENT_ID_SECRET;
				String resp = Http.get(url);
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				oneCommitMap = JsonUtils.toMap(resp);
				writeToFile(jsonFile, JsonUtils.toString(oneCommitMap));
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				oneCommitMap = JsonUtils.toMap(json);
			}
			// 保存Commit的统计数据
			Commit commit = new Commit();
			commit.sha = sha;
			commit.time = getString(oneCommitMap, "created_at");
			commit.commentCount = getInt(oneCommitMap, "commit.comment_count");
			if (stats.commits == null) {
				stats.commits = new ArrayList<Commit>();
			}
			stats.commits.add(commit);
			// 评论数
			if (commit.commentCount > 0) {
				jsonFile = new File(file, "/src/json/comments/" + sha + ".json");
				List<Map<String, Object>> commentsOfCommit = null;
				if (!jsonFile.exists()) {
					String url = (String) oneCommitMap.get("comments_url") + "?" + CLIENT_ID_SECRET;
					String resp = Http.get(url);
					if (resp == null) { // 限制到了，应该停一个小时
						throw new RuntimeException("Take a rest for one hour!");
					}
					commentsOfCommit = JsonUtils.toList(resp);
					writeToFile(jsonFile, JsonUtils.toString(commentsOfCommit));
				} else { // 直接读取文件
					String json = readFileToString(jsonFile);
					commentsOfCommit = JsonUtils.toList(json);
				}
			}
			// 匹配帐号与学号
			String homeworkMark = "/androidworks/homeworks/"; // 作业目录
			if (stats.number == null) { // 找学号
				List<Map<String, Object>> fileList = (List<Map<String, Object>>) get(oneCommitMap, "files");
				for (Map<String, Object> fileMap : fileList) {
					String filename = getString(fileMap, "filename");
					// int pos = filename.indexOf("works/");
					int pos = filename.indexOf(homeworkMark);
					if (pos > -1) { // 这是学生目录
						filename = filename.substring(pos + homeworkMark.length());
						// 后3个字母是专业代号 com-计算机班，net-网络班
						String className = filename.substring(0, 3);
						if ("com".equals(className.toLowerCase()) // 计算机班
								|| "net".equals(className.toLowerCase())) // 网络班
						{ // com1314080903223/ 或 net1314080903223/
							filename = filename.substring(3);
							pos = filename.indexOf("/");
							if (pos > -1) { // 找到学号
								stats.number = filename.substring(0, pos);
								break;
							}
						}
					}
				}
			}
		}

		// 读取Pulls
		jsonFile = getJsonFile("pulls");
		List<Map<String, Object>> pullList = new ArrayList<Map<String, Object>>();
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
					pullList = JsonUtils.toList(json);
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
					pullList.addAll(list);
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
			if (pullList.size() > 0) {
				writeToFile(jsonFile, JsonUtils.toString(pullList));
			}
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			pullList = JsonUtils.toList(json);
		}
		// 读取每一条Pull的内容
		System.out.println(pullList.size());
		for (Map<String, Object> pullMap : pullList) {
			Map<String, Object> onePullMap = null;
			int number = (Integer) pullMap.get("number");
			// 检查文件
			jsonFile = new File(file, "/src/json/pulls/" + number + ".json");
			if (!jsonFile.exists()) { // 不存在，从GitHub抓取
				String url = PULLS + "/" + number + "?" + CLIENT_ID_SECRET;
				String resp = Http.get(url);
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				onePullMap = JsonUtils.toMap(resp);
				writeToFile(jsonFile, JsonUtils.toString(onePullMap));
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				onePullMap = JsonUtils.toMap(json);
			}
			// 身份标识
			Map<String, Object> userMap = getMap(onePullMap, "user");
			String login = (String) userMap.get("login");
			Stats stats = allData.get(login);
			if (stats == null) { // 可能没有提交过？
				stats = new Stats();
				stats.login = login;
				allData.put(login, stats);
				System.out.println("新用户：" + login);
			}
			// 记录数据
			Pull pull = new Pull();
			pull.number = number;
			pull.time = getString(onePullMap, "created_at");
			pull.commentCount = getInt(onePullMap, "comments");
			pull.commitCount = getInt(onePullMap, "commits");
			if (stats.pulls == null) {
				stats.pulls = new ArrayList<Pull>();
			}
			stats.pulls.add(pull);
			// 取回评论信息
			if (pull.commentCount > 0) {
				System.out.println("Comments = " + pull.commentCount);
				// 先检查文件
				jsonFile = new File(file, "/src/json/comments/" + number + ".json");
				List<Map<String, Object>> commentsOfPull = null;
				if (!jsonFile.exists()) {
					String url = (String) onePullMap.get("comments_url") + "?" + CLIENT_ID_SECRET;
					String resp = Http.get(url);
					if (resp == null) { // 限制到了，应该停一个小时
						throw new RuntimeException("Take a rest for one hour!");
					}
					commentsOfPull = JsonUtils.toList(resp);
					writeToFile(jsonFile, JsonUtils.toString(commentsOfPull));
				} else { // 直接读取文件
					String json = readFileToString(jsonFile);
					commentsOfPull = JsonUtils.toList(json);
				}
			}
			// 取回Commits信息
			if (pull.commitCount > 0) {
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
				// 检查Commit是否已抓紧（支持重复抓取）
				for (Map<String, Object> map2 : list) {
					String sha = (String) map2.get("sha");
					Map<String, Object> commitMap = null;
					jsonFile = new File(file, "/src/json/commits/" + sha + ".json");
					if (!jsonFile.exists()) {
						String url = COMMITS + "/" + sha + "?" + CLIENT_ID_SECRET;
						String resp = Http.get(url);
						if (resp == null) { // 限制到了，应该停一个小时
							throw new RuntimeException("Take a rest for one hour!");
						}
						commitMap = JsonUtils.toMap(resp);
						writeToFile(jsonFile, JsonUtils.toString(commitMap));
					} else { // 直接读取文件
						String json = readFileToString(jsonFile);
						commitMap = JsonUtils.toMap(json);
					}
				}
			}
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
			if (issues.size() > 0) {
				writeToFile(jsonFile, JsonUtils.toString(issues));
			}
		} else { // 直接读取文件
			String json = readFileToString(jsonFile);
			issues = JsonUtils.toList(json);
		}
		// 读取每一条Issue的内容
		System.out.println("检查所有问题：" + issues.size());
		for (Map<String, Object> issueMap : issues) {
			Map<String, Object> oneIssueMap = null;
			int number = (Integer) issueMap.get("number");
			// 检查文件
			jsonFile = new File(file, "/src/json/issues/" + number + ".json");
			if (!jsonFile.exists()) { // 不存在，从GitHub抓取
				String url = ISSUES + "/" + number + "?" + CLIENT_ID_SECRET;
				String resp = Http.get(url);
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				oneIssueMap = JsonUtils.toMap(resp);
				// 判断是不是Issue html_url
				String htmlUrl = (String) oneIssueMap.get("html_url");
				if (htmlUrl.contains("/issues/")) { // 是
					writeToFile(jsonFile, JsonUtils.toString(oneIssueMap));
				}
			} else { // 直接读取文件
				String json = readFileToString(jsonFile);
				oneIssueMap = JsonUtils.toMap(json);
			}
			// 记录问题号及题目、说明 user.login
			String login = getString(oneIssueMap, "user.login");
			Stats stats = allData.get(login); // 统计信息
			if (stats == null) { // 可能没有提交过？
				stats = new Stats();
				stats.login = login;
				allData.put(login, stats);
				System.out.println("新用户：" + login);
			}
			Issue issue = new Issue();
			issue.number = number;
			issue.time = getString(oneIssueMap, "created_at");
			if (stats.issues == null) {
				stats.issues = new ArrayList<Issue>();
			}
			stats.issues.add(issue);
			// 检查事件文件
			File eventsFile = new File(file, "/src/json/issues/" + number + "_events.json");
			List<Map<String, Object>> events = new ArrayList<Map<String, Object>>();
			if (!eventsFile.exists()) { // 文件不存在，先去GitHub查询
				String url = (String) oneIssueMap.get("events_url");
				String resp = url != null ? Http.get(url + "?" + CLIENT_ID_SECRET) : null;
				if (resp == null) { // 限制到了，应该停一个小时
					throw new RuntimeException("Take a rest for one hour!");
				}
				events = JsonUtils.toList(resp);
				writeToFile(eventsFile, JsonUtils.toString(events));
			} else { // 直接读取文件
				String json = readFileToString(eventsFile);
				events = JsonUtils.toList(json);
			}
			// 记录事件数 - 交作业情况
			issue.eventCount = events.size();
		}

		// 数据抓取结果，开始生成统计数据
		String line = "Login,Number,IssueNumber,IssueCount,IssueLabels,Events,FirstTime,Pulls,Commits,Additions,Deletions,ChangedFiles,Comments,ReviewComments";
		StringBuilder sb = new StringBuilder(line + "\n"); // CSV
		List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
		List<String> issueTitleList = new ArrayList<String>();
		for (String login : allData.keySet()) {
			Stats stats = allData.get(login);
			Map<String, Object> stuMap = new HashMap<String, Object>();
			stuMap.put("login", stats.login);
			stuMap.put("number", stats.number);
			result.add(stuMap); // 保存学生的统计记录
			sb.append(stats.login + ","); // CSV
			sb.append(stats.number + ","); // CSV
			int issueNumber = 0;
			int issueCount = 0;
			String issueTitle = "";
			String issueLabels = "";
			int events = 0;
			String firstTime = "";
			if (stats.issues != null) { // 有问题号
				issueCount = stats.issues.size();
				// 可能有多个问题，
				stuMap.put("issueCount", issueCount);
				// 但是只取其中一个作为成绩
				Map<String, Object> issueMap = new HashMap<String, Object>();
				// 读取Issue信息 - 实验题目信息
				for (Issue issue : stats.issues) {
					jsonFile = new File(file, "/src/json/issues/" + issue.number + ".json");
					String json = readFileToString(jsonFile);
					Map<String, Object> map = JsonUtils.toMap(json);
					// 基本信息
					String title = getString(map, "title");
					String body = getString(map, "body");
					issueMap.put("title", title);
					issueMap.put("body", body);
					issueMap.put("number", issue.number);
					issueNumber = issue.number;
					issueTitle = title;

					// 标签
					boolean hasFinished = false; // 标记了完成
					List<String> labels = new ArrayList<String>();
					List<Map<String, Object>> list = getList(map, "labels");
					for (Map<String, Object> map2 : list) {
						String name = getString(map2, "name");
						labels.add(name);
						if ("完成".equals(name)) {
							hasFinished = true;
						}
						name = name.replace("完成", "Done");
						name = name.replace("计", "Com");
						name = name.replace("网", "Net");
						name = name.replace("迟", "Late");
						issueLabels += name + " "; // CSV
					}
					issueMap.put("labels", labels);
					// 事件
					jsonFile = new File(file, "/src/json/issues/" + issue.number + "_events.json");
					json = readFileToString(jsonFile);
					list = JsonUtils.toList(json);
					int references = 0;
					List<Map<String, Object>> eventList = new ArrayList<Map<String, Object>>();
					for (Map<String, Object> map2 : list) {
						String name = getString(map2, "event");
						String time = getString(map2, "created_at");
						if ("referenced".equals(name)) {
							references++; // 记录提交代码次数
							Map<String, Object> eventMap = new HashMap<String, Object>();
							eventMap.put("name", name);
							eventMap.put("time", time);
							eventMap.put("actor", getString(map2, "actor.login"));
							eventList.add(eventMap);
							if (references == 1) {
								firstTime = time; // CSV
							}
						}
					}
					issueMap.put("events", eventList);
					events = references; // CSV
					// 结束
					if (hasFinished) {
						break; // 标记完成
					} else if (references > 1) {
						break; // 标记完成
					}
				}
				stuMap.put("issue", issueMap);
			} else { // 该学生没有按要求创建问题
				stuMap.put("issueCount", 0);
			}
			sb.append(issueNumber + ","); // CSV
			sb.append(issueCount + ","); // CSV
			//sb.append(issueTitle + ","); // CSV
			issueTitleList.add(issueTitle);
			sb.append(issueLabels.trim() + ",");// CSV
			sb.append(events + ","); // CSV
			sb.append(firstTime + ","); // CSV
			// 统计Pulls
			if (stats.pulls != null) {
				int pullCount = stats.pulls.size();
				stuMap.put("pullCount", pullCount);
				// 统计求和
				int totalCommits = 0;
				int totalComments = 0;
				int totalAdditions = 0;
				int totalDeletions = 0;
				int totalChangedFiles = 0;
				int totalReviewComments = 0;
				pullList = new ArrayList<Map<String, Object>>();
				for (Pull pull : stats.pulls) {
					jsonFile = new File(file, "/src/json/pulls/" + pull.number + ".json");
					String json = readFileToString(jsonFile);
					Map<String, Object> map = JsonUtils.toMap(json);
					boolean merged = getBoolean(map, "merged");
					if (merged) { // 只统计合并的
						Map<String, Object> pullMap = new HashMap<String, Object>();
						String title = getString(map, "title");
						String time = getString(map, "created_at");
						int commentCount = getInt(map, "comments");
						int reviewCommentCount = getInt(map, "review_comments");
						int additionsCount = getInt(map, "additions");
						int deletionsCount = getInt(map, "deletions");
						int commitsCount = getInt(map, "commits");
						int changedFilesCount = getInt(map, "changed_files");
						pullMap.put("number", pull.number);
						pullMap.put("title", title);
						pullMap.put("time", time);
						pullMap.put("commitCount", commitsCount);
						pullMap.put("commentCount", commentCount);
						pullMap.put("additionCount", additionsCount);
						pullMap.put("deletionCount", deletionsCount);
						pullMap.put("changedFileCount", changedFilesCount);
						pullMap.put("reviewCommentCount", reviewCommentCount);
						pullList.add(pullMap);
						totalCommits += commitsCount;
						totalComments += commentCount;
						totalAdditions += additionsCount;
						totalDeletions += deletionsCount;
						totalChangedFiles += changedFilesCount;
						totalReviewComments += reviewCommentCount;
					}
				}
				stuMap.put("pulls", pullList);
				sb.append(pullCount + ","); // CSV
				// 保存总数
				stuMap.put("commitCount", totalCommits);
				stuMap.put("additionCount", totalAdditions);
				stuMap.put("deletionCount", totalDeletions);
				stuMap.put("changedFileCount", totalChangedFiles);
				stuMap.put("commentCount", totalComments);
				stuMap.put("reviewCommentCount", totalReviewComments);
				sb.append(totalCommits + ","); // CSV
				sb.append(totalAdditions + ","); // CSV
				sb.append(totalDeletions + ","); // CSV
				sb.append(totalChangedFiles + ","); // CSV
				sb.append(totalComments + ","); // CSV
				sb.append(totalReviewComments + "\n"); // CSV
			} else { // 该学生没有提交过代码
				stuMap.put("pullCount", 0);
				sb.append("0,0,0,0,0,0,0\n"); // CSV
			}
		}

		// 将结果保存为JSON
		jsonFile = new File(file, "/src/json/result.json");
		writeToFile(jsonFile, JsonUtils.toString(result));
		File csvFile = new File(file, "/src/json/result.csv");
		writeToFile(csvFile, sb.toString());
		
		// 打印Issue标题
		for(String title : issueTitleList) {
			System.out.println(title);
		}

		// 打印统计列表
		System.out.println(
				"Login\t\t\t\tNumber\t\t\tIssue\t\tEvents\t\tPulls\t\tCommits\t\tAdditions\tDeletions\tChanged Files\tComments\tReview Comments");
		for (String key : allData.keySet()) {
			Stats stats = allData.get(key);
			String showKey = key;
			// System.out.print(key);
			if (key.contains("1") && key.length() >= 18) {
				showKey = key.length() >= 18 ? key.substring(0, 18) + "... " : key;
				showKey += "\t\t";
			} else if (key.length() >= 20) {
				showKey = key.length() >= 20 ? key.substring(0, 20) + "... " : key;
				showKey += "\t";
			} else if (key.length() >= 8) {
				showKey += "\t\t\t";
			} else {
				showKey += "\t\t\t\t";
			}
			System.out.print(showKey);
			if (stats.number == null) {
				stats.number = "0000000000000";
			}
			System.out.print(stats.number + "\t\t");
			if (stats.issues != null && stats.issues.size() > 0) {
				System.out.print(stats.issues.get(0).number + "\t\t");
				System.out.print(stats.issues.get(0).eventCount + "\t\t");
			} else {
				System.out.print("0\t\t");
				System.out.print("0\t\t");
			}
			if (stats.pulls != null && stats.pulls.size() > 0) {
				System.out.print(stats.pulls.size() + "\t\t");
			} else {
				System.out.print("0\t\t");
			}
			if (stats.commits != null && stats.commits.size() > 0) {
				System.out.print(stats.commits.size() + "\t\t");
			} else {
				System.out.print("0\t\t");
			}
			System.out.println();
		}
		System.out.println("学生人数：" + allData.keySet().size());

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

	@SuppressWarnings("unchecked")
	private static Map<String, Object> getMap(Map<String, Object> map, String key) {
		return (Map<String, Object>) get(map, key);
	}

	@SuppressWarnings("unchecked")
	private static List<Map<String, Object>> getList(Map<String, Object> map, String key) {
		return (List<Map<String, Object>>) get(map, key);
	}

	private static String getString(Map<String, Object> map, String key) {
		return (String) get(map, key);
	}

	private static int getInt(Map<String, Object> map, String key) {
		return (Integer) get(map, key);
	}

	private static boolean getBoolean(Map<String, Object> map, String key) {
		return (Boolean) get(map, key);
	}

	private static Object get(Map<String, Object> map, String key) {
		if (key.contains(".")) {
			String[] keys = key.split("\\.");
			Map<String, Object> lastMap = map;
			for (int i = 0; i < keys.length - 1; i++) {
				lastMap = getMap(lastMap, keys[i]);
			}
			map = lastMap; // 最后一层Map
			key = keys[keys.length - 1]; // 最后一个Key
		}
		return map == null ? null : map.get(key);
	}
}

class Stats {
	String number;
	String login;
	List<Pull> pulls;
	List<Commit> commits;
	List<Issue> issues;
	List<Event> events;
}

class Pull {
	int number;
	String time;
	int commentCount;
	int commitCount;
}

class Comment {
	int number;
	String time;
}

class Commit {
	String sha;
	String time;
	int commentCount;
}

class Issue {
	int number;
	String time;
	int eventCount;
}

class Event {
	String name;
	String actor;
	String time;
}
