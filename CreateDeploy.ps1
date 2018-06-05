#文件MD5校验
function Md5File () {
    param(
        $filepath 
    )
    return (Get-FileHash $filepath -Algorithm MD5).Hash;
}

#比较两个文件
function CompareFile (){
    param(
        $newfile,
        $oldfile
    )

    if($newfile.Length -ne $oldfile.Length){
        Write-Host $newfile.FullName
        return $false;
    }
    else {
        $resut=((Md5File $newfile.FullName) -eq (Md5File $oldfile.FullName));
        if($resut){
            return $true;
        }
        else {
            Write-Host $newfile.FullName
            return $false;
        }
    }
}
    

#比较两个文件夹
function CompareFolder () {
    param(
        $newfolder,
        $oldfolder
    )

  

    $listnew=Get-ChildItem $newfolder |Sort-Object name
    $listold=Get-ChildItem $oldfolder |Sort-Object name
    $i=0;
    $listnew | ForEach-Object{
        $isMatch=$false;
        for($j=$i;$j -lt $listold.Count;$j++){
            if($_.Name -eq $listold[$j].Name){
                if($_ -is[IO.DirectoryInfo]){
                    $resultlist=(CompareFolder $_.FullName $listold[$j].FullName);
                }
                elseif(!(CompareFile $_ $listold[$j])){
                    $script:myupdatelist+=$_;
                    $script:mybaklist+=$listold[$j];

                }
                $isMatch=$true;
                $i=$j+1;
                break;
                
            }
        }
        if(!$isMatch){
            $script:myupdatelist+=$_;
        }
    }
    return   $script:mybaklist , $script:myupdatelist;
}

#参数1 更新的文件列表
#参数2 更新文件的来源
#参数3 目标目录
function CreateDeploy (){
    param(
        $updatelist,
        $newfolder,
        $deployfolder
    )
    
    #更新前清空
    if(!(Test-Path $deployfolder)){

        Write-Host "DeployNew" $deployfolder
        New-Item $deployfolder -ItemType Directory
    }
    else {
        Write-Host "DeployRemove:" $deployfolder
        Get-ChildItem $deployfolder | Remove-Item -Recurse -Force
    }
    Write-Host "DeployUpdate:"
    $updatelist| ForEach-Object{
        $desfolder=$deployfolder;
        $owerfolder=$_.Parent.FullName;
        if($_ -isnot [IO.DirectoryInfo]){
            $owerfolder=$_.DirectoryName;
        }
        if($owerfolder -ne $newfolder){
            $desfolder=$owerfolder.Replace($newfolder,$deployfolder);

            if(!(Test-Path $desfolder)){
                New-Item $desfolder -ItemType Directory
            }
        }

        Copy-Item $_.FullName -Destination $desfolder -Recurse
    }    


    
}

#参数1 会被覆盖的文件列表
#参数2 被覆盖的文件来源目录
#参数3 备份目录
function CreatBak () {
    param(
        $baklist,
        $olderfolder,
        $bakfolder
    )
    

    $bakfolder+="\"+(Get-Date -DisplayHint DateTime -Format yyyyMMdd_HHmmss);
    New-Item $bakfolder -ItemType Directory
    CreateDeploy $baklist $olderfolder $bakfolder
}

#参数1：新文件夹
#参数2：老文件夹
function RenameFolder()  {
    param(
        $newfolder,
        $oldfolder
    )


    $objOldFolder=Get-Item -Path $oldfolder
    Rename-item -NewName ("_"+$objOldFolder.Name+"_"+(Get-Date -DisplayHint DateTime -Format yyyyMMdd_HHmmss)) -Path $oldfolder
    Copy-Item -Path $newfolder -Destination $oldfolder -Recurse
    
}

#参数1：新发布的路径
#参数2：旧的文件路径
#参数3 增量包文件复制的目录
#参数4 备份文件目录
function DoDeploy() {

    param(
       $newfolder,
       $oldfolder,
       $deployfolder,
       $bakfolder

    )

    $script:mybaklist=@();
    $script:myupdatelist=@();
    Write-Host "Compare dif:"

    $DeployupdateList=CompareFolder $newfolder $oldfolder
    if($DeployupdateList[0].Count -gt 0){
        Write-Host "Create Bak"
        #CreatBak $DeployupdateList[0] $oldfolder $bakfolder
    }
    else {
        Write-Host "No bak"
    }
    if($DeployupdateList[1].Count -gt 0){
        Write-Host "Create deploy"
        CreateDeploy $DeployupdateList[1] $newfolder $deployfolder
        #RenameFolder $newfolder $oldfolder
    }
    else {
        Write-Host "No deploy"
    }

}

function RUN () {
    Write-Host "Begin...";
    $project="wp2013";

    $newfolder="D:\web\pt\"+$project
    $oldfolder="D:\web\ptold\"+$project
    $deployfolder="D:\web\ptdeploy\"+$project
    $bakfolder="D:\web\ptbak\"+$project
    DoDeploy $newfolder $oldfolder $deployfolder $bakfolder 
    Write-Host "Over!"

}
#执行
RUN 