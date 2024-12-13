import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:example/models/news_article.dart';
import 'package:example/news_app/data/news_repository.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc(this._newsRepository) : super(NewsInitial()) {
    on<LoadNewsEvent>((event, emit) async {
      emit(NewsLoading());
      try {
        final news = await _newsRepository.getNews();
        emit(NewsLoaded(news));
      } catch (e) {
        emit(NewsError(e.toString()));
        print(e);
      }
    });
  }
}
