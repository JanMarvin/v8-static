# v8-static

```
# checkout static branch
git clone https://github.com/JanMarvin/V8
git checkout static

# switch to directory
cd V8/inst

# download static v8
curl -LJO https://github.com/JanMarvin/v8-static/releases/download/8.6.395.17/v8-static-8.6.395.17-1-x86_64.pkg.tar.zst

# extract v8 folder
tar -I zstd -xf v8-static-8.6.395.17-1-x86_64.pkg.tar.zst v8 

cd ../..

R CMD INSTALL .
```
