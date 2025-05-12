import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttr_app/data/datasources/auth_remote_data_source.dart';
import 'package:fluttr_app/data/datasources/child_remote_data_source.dart';
import 'package:fluttr_app/data/repositories/auth_repostory_impl.dart';
import 'package:fluttr_app/data/repositories/child_repository_impl.dart';
import 'package:fluttr_app/domain/repositories/auth_repository.dart';
import 'package:fluttr_app/domain/repositories/child_repository.dart';
import 'package:fluttr_app/domain/usecases/auth/get_current_user.dart';
import 'package:fluttr_app/domain/usecases/auth/login_usecase.dart';
import 'package:fluttr_app/domain/usecases/auth/logout_usecase.dart';
import 'package:fluttr_app/domain/usecases/auth/signup_usecase.dart';
import 'package:fluttr_app/domain/usecases/child/add_child_usecase.dart';
import 'package:fluttr_app/domain/usecases/child/delete_child_usecase.dart';
import 'package:fluttr_app/domain/usecases/child/get_child_usecase.dart';
import 'package:fluttr_app/domain/usecases/child/get_children_usecase.dart';
import 'package:fluttr_app/domain/usecases/child/update_child_usecase.dart';
import 'package:fluttr_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:fluttr_app/presentation/bloc/child/child_bloc.dart';
import 'package:fluttr_app/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt
    .instance; // sl is short for service locatorfinal SharedPreferences sharedPreferences = sl<SharedPreferences>();
Future<void> init() async {
  // BLoC
  sl.registerFactory(() =>
      AuthBloc(login: sl(), signup: sl(), logout: sl(), getCurrentUser: sl()));

  sl.registerFactory(() => ChildBloc(
        getChildren: sl(),
        addChild: sl(),
        updateChild: sl(),
        deleteChild: sl(),
      ));
  sl.registerFactory(() => SelectedChildBloc(
      sharedPreferences: sl(),
      getChildUseCase: sl())); // Register SelectedChildBloc

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton(() => GetChildrenUseCase(sl()));
  sl.registerLazySingleton(() => AddChildUseCase(sl()));
  sl.registerLazySingleton(() => UpdateChildUseCase(sl()));
  sl.registerLazySingleton(() => DeleteChildUseCase(sl()));

  sl.registerLazySingleton(() => GetChildUseCase(sl())); //

  // Repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ChildRepository>(
      () => ChildRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: sl())); // Or Firebase
  sl.registerLazySingleton<ChildRemoteDataSource>(
      () => ChildRemoteDataSourceImpl()); // Or Firebase

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  sl.registerLazySingleton(
      () => sharedPreferences); // Uncomment if using SharedPreferences
}
