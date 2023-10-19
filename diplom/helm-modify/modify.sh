cd %TEMP_HELM_REPO_FOLDER_NAME%/%HELM_REPO_NAME%;

# Update chart version.
cd %WEB_APP_NAME%;
cat Chart.yaml | sed -e "s/version:.*/version: %COMMIT_TAG%/" > Chart.tmp.yaml
mv Chart.tmp.yaml Chart.yaml

cat Chart.yaml | sed -e "s/appVersion:.*/appVersion: \"%COMMIT_TAG%\"/" > Chart.tmp.yaml
mv Chart.tmp.yaml Chart.yaml

# Update image tag.
cat values.yaml | sed -e "s/tag:.*/tag: \"%COMMIT_TAG%\"/" > values.tmp.yaml
mv values.tmp.yaml values.yaml

cd ..;

# Create Helm-archive.
helm package %WEB_APP_NAME% -d charts;

# Update Helm-index file.
helm repo index charts;

# Update repository.
git add .;
git config --global user.email "%USER_EMAIL%"
git config --global user.name "%USER_NAME%"
git commit -m "Build #%build.number%"
git push origin -f;

# Cleanout.
cd ..;
rm test/ -rdf;

# Update previous commit tag.
echo "##teamcity[setParameter name='PREV_COMMIT_TAG' value='$commit_tag']"
