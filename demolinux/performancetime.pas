unit PerformanceTime;
{  =============================================================================
Модуль PerformanceTime содержит описание класса  TPerformanceTime, который
позволяет измерить время выполнения куска кода. Необходимо инициализировать
переменную типа TPerformanceTime, выполнить метод Start. проделать работу (код)
Выполнить метод Stop, после чего в св-ве Delay будет время выполнения кода
в секундах.
Пример:
     T:=TPerformanceTime.Create;
     T.Start;
     Sleep(1000);
     T.Stop;
     Caption:=FloatToStr(T.Delay);//покажет время равное 1 секунде +/- погрешность

Так же в классе есть учет погрешности за счет вызова внутренних процедур класса.
За это отвечает параметр в конструкторе. если он True то будет учет погрешности
(задержка самого таймера, за счет вызова процедур)

Примечание: Позволяет измерять время выполнения кода. Если код "быстрый" можно
использовать for I:=1 to N do (Код), после чего полученное время разделить
на N, При этом чем выше N тем меньше будет дисперсия.
Чем выше частота процессора, то по идее точность должна быть выше, по крайней
мере в Windows.

Среда разработки: Lazarus v0.9.29 beta и выше
Компилятор:       FPC v 2.4.1 и выше
Автор: Maxizar
Дата создания: 03.03.2010
Дата редактирования: 12.01.2011
}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  {$IFDEF windows}
  Windows;
  {$ENDIF}
  {$IFDEF UNIX}
  Unix, BaseUnix;
  {$ENDIF}


  Type
    TPerformanceTime=class
      private
        FDelay    :Extended;   //измеренное время в секундах
        TimerDelay:Extended;   //Задержка (время) самого вычисления в секундах
        StartTime :Extended;   //Время начала теста в секундах

      public
        constructor Create(EnabledTimerDelay:Boolean=True);

        property  Delay:Extended read FDelay;
        procedure Start;
        procedure Stop;
   end;

  Function  GetTimeInSec:Real;   //вернет время в секундах, с начало работы ОС

implementation


function GetTimeInSec: Real;
var
  {$IFDEF windows}
  StartCount, Freq: Int64;
  {$ENDIF}

   {$IFDEF UNIX}
  TimeLinux:timeval;
  {$ENDIF}
begin
  {$IFDEF windows}
   if QueryPerformanceCounter(StartCount) then //возвращает текущее значение счетчика
    begin
      QueryPerformanceFrequency(Freq);   //Кол-во тиков в секунду
      Result:=StartCount/Freq;           //Результат в секундах
    end
  else
    Result:=GetTickCount*1000;           //*1000, т.к  GetTickCount вернет милиСекунды
  {$ENDIF}

  {$IFDEF UNIX}
   fpGetTimeOfDay(@TimeLinux,nil);
   Result:=TimeLinux.tv_sec + TimeLinux.tv_usec/1000000;
  {$ENDIF}
end;

{ TPerformanceTime }
//------------------------------------------------------------------//
constructor TPerformanceTime.Create(EnabledTimerDelay: Boolean);
var TempTime,TempValue:Real;
begin
  TimerDelay:=0;

  if EnabledTimerDelay then
   begin
    TempValue :=GetTimeInSec;    //Первый раз холостой, чтобы подгрузить нужные системные dll
                                 //Но за одно и записали в TempValue число.
    TempTime  :=GetTimeInSec;    //Теперь уже за правду записали время.
    TempValue :=TempValue-GetTimeInSec-TempTime;  //Тут пытаемся сделать работу подобной проц Stop
    TimerDelay:=GetTimeInSec-TempTime;            //подсчитали потери (погрешность) самого таймера (по идее проц Stop)
   end;
end;
//------------------------------------------------------------------//
procedure TPerformanceTime.Start;
begin
   StartTime:=GetTimeInSec;
end;
//------------------------------------------------------------------//
procedure TPerformanceTime.Stop;
begin
   FDelay:=GetTimeInSec-StartTime-TimerDelay;
end;
end.
