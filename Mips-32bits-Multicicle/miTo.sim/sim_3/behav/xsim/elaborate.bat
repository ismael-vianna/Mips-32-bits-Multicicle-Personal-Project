@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.3 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Fri Jul 23 16:16:51 -0300 2021
REM SW Build 3173277 on Wed Apr  7 05:07:49 MDT 2021
REM
REM IP Build 3174024 on Wed Apr  7 23:42:35 MDT 2021
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
REM elaborate design
echo "xelab -wto 6b16120a2d824e05bcce677717a8d6fd --incr --debug typical --relax --mt 2 -L mito -L oi -L unisims_ver -L secureip --snapshot testebenche_behav oi.testebenche oi.glbl -log elaborate.log"
call xelab  -wto 6b16120a2d824e05bcce677717a8d6fd --incr --debug typical --relax --mt 2 -L mito -L oi -L unisims_ver -L secureip --snapshot testebenche_behav oi.testebenche oi.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
