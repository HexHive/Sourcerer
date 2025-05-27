; ModuleID = 'typecheck.cpp'
source_filename = "typecheck.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.BaseType = type { i32 (...)**, i64, [20 x i32] }
%struct.AllocType = type { %struct.IntermediateType, %struct.IntermediateBaseType.base, i64, %struct.BaseType }
%struct.IntermediateType = type { i32 (...)**, i32, i32 }
%struct.IntermediateBaseType.base = type { %struct.IntermediateType2, i32, i32 }
%struct.IntermediateType2 = type { i32 (...)**, i32, i32 }
%struct.BaseDerivedType = type { %struct.BaseType, i8, i8, i8, i8, i8, i8, i8, i8 }

$_ZTS8BaseType = comdat any

$_ZTI8BaseType = comdat any

$_ZTS15BaseDerivedType = comdat any

$_ZTI15BaseDerivedType = comdat any

@_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global i8*
@_ZTS8BaseType = linkonce_odr dso_local constant [10 x i8] c"8BaseType\00", comdat, align 1
@_ZTI8BaseType = linkonce_odr dso_local constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([10 x i8], [10 x i8]* @_ZTS8BaseType, i32 0, i32 0) }, comdat, align 8
@_ZTVN10__cxxabiv120__si_class_type_infoE = external dso_local global i8*
@_ZTS15BaseDerivedType = linkonce_odr dso_local constant [18 x i8] c"15BaseDerivedType\00", comdat, align 1
@_ZTI15BaseDerivedType = linkonce_odr dso_local constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([18 x i8], [18 x i8]* @_ZTS15BaseDerivedType, i32 0, i32 0), i8* bitcast ({ i8*, i8* }* @_ZTI8BaseType to i8*) }, comdat, align 8
@.str = private unnamed_addr constant [4 x i8] c"ok\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local %struct.BaseType* @_Z10getbaseptrP9AllocType(%struct.AllocType* %allocptr) #0 {
entry:
  %allocptr.addr = alloca %struct.AllocType*, align 8
  store %struct.AllocType* %allocptr, %struct.AllocType** %allocptr.addr, align 8
  %0 = load %struct.AllocType*, %struct.AllocType** %allocptr.addr, align 8
  %1 = icmp eq %struct.AllocType* %0, null
  br i1 %1, label %cast.end, label %cast.notnull

cast.notnull:                                     ; preds = %entry
  %2 = bitcast %struct.AllocType* %0 to i8**
  %vtable = load i8*, i8** %2, align 8
  %vbase.offset.ptr = getelementptr i8, i8* %vtable, i64 -24
  %3 = bitcast i8* %vbase.offset.ptr to i64*
  %vbase.offset = load i64, i64* %3, align 8
  %4 = bitcast %struct.AllocType* %0 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %4, i64 %vbase.offset
  %5 = bitcast i8* %add.ptr to %struct.BaseType*
  br label %cast.end

cast.end:                                         ; preds = %cast.notnull, %entry
  %cast.result = phi %struct.BaseType* [ %5, %cast.notnull ], [ null, %entry ]
  ret %struct.BaseType* %cast.result
}

; Function Attrs: noinline optnone uwtable
define dso_local void @_Z9checkcastP8BaseType(%struct.BaseType* %ptr) #1 {
entry:
  %ptr.addr = alloca %struct.BaseType*, align 8
  store %struct.BaseType* %ptr, %struct.BaseType** %ptr.addr, align 8
  %0 = load %struct.BaseType*, %struct.BaseType** %ptr.addr, align 8
  %1 = icmp eq %struct.BaseType* %0, null
  br i1 %1, label %dynamic_cast.null, label %dynamic_cast.notnull

dynamic_cast.notnull:                             ; preds = %entry
  %2 = bitcast %struct.BaseType* %0 to i8*
  %3 = call i8* @__dynamic_cast(i8* %2, i8* bitcast ({ i8*, i8* }* @_ZTI8BaseType to i8*), i8* bitcast ({ i8*, i8*, i8* }* @_ZTI15BaseDerivedType to i8*), i64 0) #6
  %4 = bitcast i8* %3 to %struct.BaseDerivedType*
  br label %dynamic_cast.end

dynamic_cast.null:                                ; preds = %entry
  br label %dynamic_cast.end

dynamic_cast.end:                                 ; preds = %dynamic_cast.null, %dynamic_cast.notnull
  %5 = phi %struct.BaseDerivedType* [ %4, %dynamic_cast.notnull ], [ null, %dynamic_cast.null ]
  %cmp = icmp eq %struct.BaseDerivedType* %5, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %dynamic_cast.end
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0))
  call void @exit(i32 -1) #7
  unreachable

if.end:                                           ; preds = %dynamic_cast.end
  ret void
}

; Function Attrs: nounwind readonly
declare dso_local i8* @__dynamic_cast(i8*, i8*, i8*, i64) #2

declare dso_local i32 @printf(i8*, ...) #3

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) #4

; Function Attrs: noinline norecurse optnone uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) #5 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  store i32 0, i32* %retval, align 4
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %0 = load i32, i32* %argc.addr, align 4
  %mul = mul nsw i32 %0, 10
  call void @_Z8allocatei(i32 %mul)
  ret i32 0
}

declare dso_local void @_Z8allocatei(i32) #3

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { noinline norecurse optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind }
attributes #7 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.0 (git@github.com:HexHive/Typesafety-vtable.git 7ba546d21d39319cbadc89af2c9266e2516d480b)"}
