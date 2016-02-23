clear all;

data=loadjson('result.json');

[x, stu_num] = size(data);

% 处理每一个学生的实验提交数据
for ii=1:stu_num
    stu = data(ii);
    pulls = stu{1,1}.pulls;
    [x,pull_num] = size(pulls);
    stu_pulls(ii)=pull_num;
    pull_comment_count = 0;
    % 遍历每一个实验数据
    for jj=1:pull_num
        pull = pulls(jj);
        pull_comment_count = pull_comment_count + pull{1,1}.commentCount;
        commit_comment_count = 0;
        commits = pull{1,1}.commits;
        [x, commit_num] = size(commits);
        pull_commits(jj)=commit_num;
        for kk=1:commit_num
            commit = commits(kk);
            commit_comment_count = commit_comment_count + commit{1,1}.commentCount;
        end
        pull_comment_count = pull_comment_count + commit_comment_count;
        pull_comments(jj)= pull_comment_count;
    end
    stu_commits(ii) = mean(pull_commits);
    stu_comments(ii) = pull_comment_count;
end

% 计算平均值
mean_pulls = mean(stu_pulls);
mean_commits = mean(stu_commits);
mean_comments = mean(pull_comments);