; ModuleID = 'allocate.cpp'
source_filename = "allocate.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.AllocType = type { %struct.IntermediateType, %struct.IntermediateBaseType.base, i64, %struct.BaseType }
%struct.IntermediateType = type { i32 (...)**, i32, i32 }
%struct.IntermediateBaseType.base = type { %struct.IntermediateType2, i32, i32 }
%struct.IntermediateType2 = type { i32 (...)**, i32, i32 }
%struct.BaseType = type { i32 (...)**, i64, [20 x i32] }
%struct.IntermediateBaseType = type { %struct.IntermediateType2, i32, i32, %struct.BaseType }

$_ZN9AllocTypeC1Ev = comdat any

$_ZN8BaseTypeC2Ev = comdat any

$_ZN16IntermediateTypeC2Ev = comdat any

$_ZN20IntermediateBaseTypeC2Ev = comdat any

$_ZN17IntermediateType2C2Ev = comdat any

$_ZTV9AllocType = comdat any

$_ZTT9AllocType = comdat any

$_ZTC9AllocType16_20IntermediateBaseType = comdat any

$_ZTS20IntermediateBaseType = comdat any

$_ZTS17IntermediateType2 = comdat any

$_ZTI17IntermediateType2 = comdat any

$_ZTS8BaseType = comdat any

$_ZTI8BaseType = comdat any

$_ZTI20IntermediateBaseType = comdat any

$_ZTS9AllocType = comdat any

$_ZTS16IntermediateType = comdat any

$_ZTI16IntermediateType = comdat any

$_ZTI9AllocType = comdat any

$_ZTV8BaseType = comdat any

$_ZTV16IntermediateType = comdat any

$_ZTV17IntermediateType2 = comdat any

@_ZTV9AllocType = linkonce_odr dso_local unnamed_addr constant { [3 x i8*], [3 x i8*], [2 x i8*] } { [3 x i8*] [i8* inttoptr (i64 48 to i8*), i8* null, i8* bitcast ({ i8*, i8*, i32, i32, i8*, i64, i8*, i64 }* @_ZTI9AllocType to i8*)], [3 x i8*] [i8* inttoptr (i64 32 to i8*), i8* inttoptr (i64 -16 to i8*), i8* bitcast ({ i8*, i8*, i32, i32, i8*, i64, i8*, i64 }* @_ZTI9AllocType to i8*)], [2 x i8*] [i8* inttoptr (i64 -48 to i8*), i8* bitcast ({ i8*, i8*, i32, i32, i8*, i64, i8*, i64 }* @_ZTI9AllocType to i8*)] }, comdat, align 8
@_ZTT9AllocType = linkonce_odr dso_local unnamed_addr constant [5 x i8*] [i8* bitcast (i8** getelementptr inbounds ({ [3 x i8*], [3 x i8*], [2 x i8*] }, { [3 x i8*], [3 x i8*], [2 x i8*] }* @_ZTV9AllocType, i32 0, inrange i32 0, i32 3) to i8*), i8* bitcast (i8** getelementptr inbounds ({ [3 x i8*], [2 x i8*] }, { [3 x i8*], [2 x i8*] }* @_ZTC9AllocType16_20IntermediateBaseType, i32 0, inrange i32 0, i32 3) to i8*), i8* bitcast (i8** getelementptr inbounds ({ [3 x i8*], [2 x i8*] }, { [3 x i8*], [2 x i8*] }* @_ZTC9AllocType16_20IntermediateBaseType, i32 0, inrange i32 1, i32 2) to i8*), i8* bitcast (i8** getelementptr inbounds ({ [3 x i8*], [3 x i8*], [2 x i8*] }, { [3 x i8*], [3 x i8*], [2 x i8*] }* @_ZTV9AllocType, i32 0, inrange i32 1, i32 3) to i8*), i8* bitcast (i8** getelementptr inbounds ({ [3 x i8*], [3 x i8*], [2 x i8*] }, { [3 x i8*], [3 x i8*], [2 x i8*] }* @_ZTV9AllocType, i32 0, inrange i32 2, i32 2) to i8*)], comdat, align 8
@_ZTC9AllocType16_20IntermediateBaseType = linkonce_odr dso_local unnamed_addr constant { [3 x i8*], [2 x i8*] } { [3 x i8*] [i8* inttoptr (i64 32 to i8*), i8* null, i8* bitcast ({ i8*, i8*, i32, i32, i8*, i64, i8*, i64 }* @_ZTI20IntermediateBaseType to i8*)], [2 x i8*] [i8* inttoptr (i64 -32 to i8*), i8* bitcast ({ i8*, i8*, i32, i32, i8*, i64, i8*, i64 }* @_ZTI20IntermediateBaseType to i8*)] }, comdat, align 8
@_ZTVN10__cxxabiv121__vmi_class_type_infoE = external dso_local global i8*
@_ZTS20IntermediateBaseType = linkonce_odr dso_local constant [23 x i8] c"20IntermediateBaseType\00", comdat, align 1
@_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global i8*
@_ZTS17IntermediateType2 = linkonce_odr dso_local constant [20 x i8] c"17IntermediateType2\00", comdat, align 1
@_ZTI17IntermediateType2 = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @_ZTS17IntermediateType2, i32 0, i32 0) }, comdat, align 8
@_ZTS8BaseType = linkonce_odr dso_local constant [10 x i8] c"8BaseType\00", comdat, align 1
@_ZTI8BaseType = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([10 x i8], [10 x i8]* @_ZTS8BaseType, i32 0, i32 0) }, comdat, align 8
@_ZTI20IntermediateBaseType = linkonce_odr dso_local constant { i8*, i8*, i32, i32, i8*, i64, i8*, i64 } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv121__vmi_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([23 x i8], [23 x i8]* @_ZTS20IntermediateBaseType, i32 0, i32 0), i32 0, i32 2, i8* bitcast ({ i8*, i8* }* @_ZTI17IntermediateType2 to i8*), i64 2, i8* bitcast ({ i8*, i8* }* @_ZTI8BaseType to i8*), i64 -6141 }, comdat, align 8
@_ZTS9AllocType = linkonce_odr dso_local constant [11 x i8] c"9AllocType\00", comdat, align 1
@_ZTS16IntermediateType = linkonce_odr dso_local constant [19 x i8] c"16IntermediateType\00", comdat, align 1
@_ZTI16IntermediateType = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([19 x i8], [19 x i8]* @_ZTS16IntermediateType, i32 0, i32 0) }, comdat, align 8
@_ZTI9AllocType = linkonce_odr dso_local constant { i8*, i8*, i32, i32, i8*, i64, i8*, i64 } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv121__vmi_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([11 x i8], [11 x i8]* @_ZTS9AllocType, i32 0, i32 0), i32 0, i32 2, i8* bitcast ({ i8*, i8* }* @_ZTI16IntermediateType to i8*), i64 2, i8* bitcast ({ i8*, i8*, i32, i32, i8*, i64, i8*, i64 }* @_ZTI20IntermediateBaseType to i8*), i64 4098 }, comdat, align 8
@_ZTV8BaseType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI8BaseType to i8*)] }, comdat, align 8
@_ZTV16IntermediateType = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI16IntermediateType to i8*)] }, comdat, align 8
@_ZTV17IntermediateType2 = linkonce_odr dso_local unnamed_addr constant { [2 x i8*] } { [2 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI17IntermediateType2 to i8*)] }, comdat, align 8

; Function Attrs: noinline optnone uwtable
define dso_local void @_Z8allocatei(i32 %count) #0 {
entry:
  %count.addr = alloca i32, align 4
  %ptr = alloca %struct.AllocType*, align 8
  store i32 %count, i32* %count.addr, align 4
  %call = call i8* @_Znwm(i64 144) #5
  %0 = bitcast i8* %call to %struct.AllocType*
  %1 = bitcast %struct.AllocType* %0 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %1, i8 0, i64 144, i1 false)
  call void @_ZN9AllocTypeC1Ev(%struct.AllocType* %0) #6
  store %struct.AllocType* %0, %struct.AllocType** %ptr, align 8
  %2 = load %struct.AllocType*, %struct.AllocType** %ptr, align 8
  %call1 = call %struct.BaseType* @_Z10getbaseptrP9AllocType(%struct.AllocType* %2)
  call void @_Z9checkcastP8BaseType(%struct.BaseType* %call1)
  ret void
}

; Function Attrs: nobuiltin
declare dso_local noalias i8* @_Znwm(i64) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN9AllocTypeC1Ev(%struct.AllocType* %this) unnamed_addr #3 comdat align 2 {
entry:
  %this.addr = alloca %struct.AllocType*, align 8
  store %struct.AllocType* %this, %struct.AllocType** %this.addr, align 8
  %this1 = load %struct.AllocType*, %struct.AllocType** %this.addr, align 8
  %0 = bitcast %struct.AllocType* %this1 to i8*
  %1 = getelementptr inbounds i8, i8* %0, i64 48
  %2 = bitcast i8* %1 to %struct.BaseType*
  call void @_ZN8BaseTypeC2Ev(%struct.BaseType* %2) #6
  %3 = bitcast %struct.AllocType* %this1 to %struct.IntermediateType*
  call void @_ZN16IntermediateTypeC2Ev(%struct.IntermediateType* %3) #6
  %4 = bitcast %struct.AllocType* %this1 to i8*
  %5 = getelementptr inbounds i8, i8* %4, i64 16
  %6 = bitcast i8* %5 to %struct.IntermediateBaseType*
  call void @_ZN20IntermediateBaseTypeC2Ev(%struct.IntermediateBaseType* %6, i8** getelementptr inbounds ([5 x i8*], [5 x i8*]* @_ZTT9AllocType, i64 0, i64 1)) #6
  %7 = bitcast %struct.AllocType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [3 x i8*], [3 x i8*], [2 x i8*] }, { [3 x i8*], [3 x i8*], [2 x i8*] }* @_ZTV9AllocType, i32 0, inrange i32 0, i32 3) to i32 (...)**), i32 (...)*** %7, align 8
  %8 = bitcast %struct.AllocType* %this1 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %8, i64 16
  %9 = bitcast i8* %add.ptr to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [3 x i8*], [3 x i8*], [2 x i8*] }, { [3 x i8*], [3 x i8*], [2 x i8*] }* @_ZTV9AllocType, i32 0, inrange i32 1, i32 3) to i32 (...)**), i32 (...)*** %9, align 8
  %10 = bitcast %struct.AllocType* %this1 to i8*
  %add.ptr2 = getelementptr inbounds i8, i8* %10, i64 48
  %11 = bitcast i8* %add.ptr2 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [3 x i8*], [3 x i8*], [2 x i8*] }, { [3 x i8*], [3 x i8*], [2 x i8*] }* @_ZTV9AllocType, i32 0, inrange i32 2, i32 2) to i32 (...)**), i32 (...)*** %11, align 8
  ret void
}

declare dso_local void @_Z9checkcastP8BaseType(%struct.BaseType*) #4

declare dso_local %struct.BaseType* @_Z10getbaseptrP9AllocType(%struct.AllocType*) #4

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN8BaseTypeC2Ev(%struct.BaseType* %this) unnamed_addr #3 comdat align 2 {
entry:
  %this.addr = alloca %struct.BaseType*, align 8
  store %struct.BaseType* %this, %struct.BaseType** %this.addr, align 8
  %this1 = load %struct.BaseType*, %struct.BaseType** %this.addr, align 8
  %0 = bitcast %struct.BaseType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV8BaseType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %0, align 8
  %longMember = getelementptr inbounds %struct.BaseType, %struct.BaseType* %this1, i32 0, i32 1
  store i64 0, i64* %longMember, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN16IntermediateTypeC2Ev(%struct.IntermediateType* %this) unnamed_addr #3 comdat align 2 {
entry:
  %this.addr = alloca %struct.IntermediateType*, align 8
  store %struct.IntermediateType* %this, %struct.IntermediateType** %this.addr, align 8
  %this1 = load %struct.IntermediateType*, %struct.IntermediateType** %this.addr, align 8
  %0 = bitcast %struct.IntermediateType* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV16IntermediateType, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %0, align 8
  %intMember1 = getelementptr inbounds %struct.IntermediateType, %struct.IntermediateType* %this1, i32 0, i32 1
  store i32 0, i32* %intMember1, align 8
  %intMember2 = getelementptr inbounds %struct.IntermediateType, %struct.IntermediateType* %this1, i32 0, i32 2
  store i32 0, i32* %intMember2, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN20IntermediateBaseTypeC2Ev(%struct.IntermediateBaseType* %this, i8** %vtt) unnamed_addr #3 comdat align 2 {
entry:
  %this.addr = alloca %struct.IntermediateBaseType*, align 8
  %vtt.addr = alloca i8**, align 8
  store %struct.IntermediateBaseType* %this, %struct.IntermediateBaseType** %this.addr, align 8
  store i8** %vtt, i8*** %vtt.addr, align 8
  %this1 = load %struct.IntermediateBaseType*, %struct.IntermediateBaseType** %this.addr, align 8
  %vtt2 = load i8**, i8*** %vtt.addr, align 8
  %0 = bitcast %struct.IntermediateBaseType* %this1 to %struct.IntermediateType2*
  call void @_ZN17IntermediateType2C2Ev(%struct.IntermediateType2* %0) #6
  %1 = load i8*, i8** %vtt2, align 8
  %2 = bitcast %struct.IntermediateBaseType* %this1 to i32 (...)***
  %3 = bitcast i8* %1 to i32 (...)**
  store i32 (...)** %3, i32 (...)*** %2, align 8
  %4 = getelementptr inbounds i8*, i8** %vtt2, i64 1
  %5 = load i8*, i8** %4, align 8
  %6 = bitcast %struct.IntermediateBaseType* %this1 to i8**
  %vtable = load i8*, i8** %6, align 8
  %vbase.offset.ptr = getelementptr i8, i8* %vtable, i64 -24
  %7 = bitcast i8* %vbase.offset.ptr to i64*
  %vbase.offset = load i64, i64* %7, align 8
  %8 = bitcast %struct.IntermediateBaseType* %this1 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %8, i64 %vbase.offset
  %9 = bitcast i8* %add.ptr to i32 (...)***
  %10 = bitcast i8* %5 to i32 (...)**
  store i32 (...)** %10, i32 (...)*** %9, align 8
  %intMember1 = getelementptr inbounds %struct.IntermediateBaseType, %struct.IntermediateBaseType* %this1, i32 0, i32 1
  store i32 0, i32* %intMember1, align 8
  %intMember2 = getelementptr inbounds %struct.IntermediateBaseType, %struct.IntermediateBaseType* %this1, i32 0, i32 2
  store i32 0, i32* %intMember2, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define linkonce_odr dso_local void @_ZN17IntermediateType2C2Ev(%struct.IntermediateType2* %this) unnamed_addr #3 comdat align 2 {
entry:
  %this.addr = alloca %struct.IntermediateType2*, align 8
  store %struct.IntermediateType2* %this, %struct.IntermediateType2** %this.addr, align 8
  %this1 = load %struct.IntermediateType2*, %struct.IntermediateType2** %this.addr, align 8
  %0 = bitcast %struct.IntermediateType2* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @_ZTV17IntermediateType2, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %0, align 8
  %intMember1 = getelementptr inbounds %struct.IntermediateType2, %struct.IntermediateType2* %this1, i32 0, i32 1
  store i32 0, i32* %intMember1, align 8
  %intMember2 = getelementptr inbounds %struct.IntermediateType2, %struct.IntermediateType2* %this1, i32 0, i32 2
  store i32 0, i32* %intMember2, align 4
  ret void
}

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nobuiltin "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { builtin }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.0 (git@github.com:HexHive/Typesafety-vtable.git 7ba546d21d39319cbadc89af2c9266e2516d480b)"}
