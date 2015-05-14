```
HEAD   5969759c44f9d3c224efd917fd7832d3d4822b41 implement with github_api gem
HEAD~1 8ff714b3b86acb0656e486a638b060b0c7b31858 implement with oauth2 and octokit gems
HEAD~2 ae9a4bae074793171866f6466c4f364b0675c8c3 implement with oauth2 gem
HEAD~3 33134f7e67c1dab57b13260fc8cfacf3dba7abf0 implement hand-rolled oauth
HEAD~4 5a9ff5e5bd6a8cd97ed299ff1f40233bc23e52c3 add README
```

```
git tag -d baseapp
git branch -D handrolled oauth2gem octokit github_api
git push origin --delete handrolled oauth2gem octokit github_api

git tag baseapp HEAD~4

git checkout -b handrolled baseapp
git cherry-pick master~3
echo $(git last) > sha_list
git checkout master

git checkout -b oauth2gem baseapp
git cherry-pick master~3 master~2
git reset --soft HEAD~2
git commit -m "implement with oauth2 gem"
echo $(git last) >> sha_list
git checkout master

git checkout -b octokit baseapp
git cherry-pick master~3 master~2 master~1
git reset --soft HEAD~3
git commit -m "implement with oauth2 and octokit gems"
echo $(git last) >> sha_list
git checkout master

git checkout -b github_api baseapp
git cherry-pick master~3 master~2 master~1 master
git reset --soft HEAD~4
git commit -m "implement with github_api gem"
echo $(git last) >> sha_list
git checkout master

git push origin --all --force
git push --tags
```

... make changes ..

```
git commit -m "squash"
git reset --soft HEAD~2
git commit -m "..."
git sha
#=> c7f3a00a796f5053405137f1becf361906a51bfd (HEAD)

git checkout handrolled
git cherry-pick master
git checkout oauth2gem
git cherry-pick master
git checkout octokit
git cherry-pick master
git checkout github_api
git cherry-pick master
git push origin --all
```