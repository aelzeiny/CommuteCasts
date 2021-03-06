require_relative '../concerns/itunes_rss_api'

class Api::PodcastsController < ApplicationController
  def create
    # first check if categories exist
    @pod = Podcast.find_by(itunes_id: params[:podcast][:itunes_id])
    if @pod
      render :create
      return
    end
    @pod = Podcast.new(podcast_params)
    if @pod.save
      params[:podcast][:itunes_genres].each do |itunes_id|
        categ = Category.find_by(itunes_id: itunes_id)
        if categ
          PodcastCategory.create(category_id: categ.id, podcast_id: @pod.id)
        end
      end
      render :create
    else
      render json: @pod.errors.full_messages, status: 422
    end
  end

  def ensure_create
    @pod = Podcast.find_by(itunes_id: params[:id])
    unless @pod
      lookup_values = ITunesRssAPI.lookup_podcast(params[:id])
      @pod = create_podcast(parse_lookup(lookup_values))
    end
    render :create
  end

  def search
    @response = ITunesRssAPI.search_podcasts(params[:term])
    render :search
  end

  def top
    @response =  params.has_key?(:genre_id) ?
      ITunesRssAPI.top_podcasts(100, params[:genre_id].to_i)
      : ITunesRssAPI.top_podcasts(100)
    render :top
  end

  #NB: Podcast Ids are based on itunes ids
  def show
    @podcast = Podcast.find_by(itunes_id: params[:id])
    @feed = ITunesRssAPI.parse_feed(@podcast.feed_url)
    @episodes = get_episodes(@feed)
    render :show
  end

  def timeline
    unless params[:podcast_ids]
      render json: ["Invalid podcast ids"], status: 422
      return
    end
    podcasts = params[:podcast_ids].map do |id|
      Podcast.find_by(itunes_id: id)
    end
    episodes = []
    podcasts.each do |cast|
      feed = ITunesRssAPI.parse_feed(cast.feed_url)
      eps = get_episodes(feed)
      eps.each do |ep|
        ep[:podcast] = cast
      end
      episodes.concat(eps)
    end
    sorted_episodes = episodes.sort do |a, b|
      (b[:published]) <=> (a[:published])
    end
    render json: sorted_episodes
  end

  private

  def get_episodes(feed)
    episodes = []
    feed.entries.each do |ep|
      episode = {
        title: ep.title,
        summary: ep.summary,
        published: ep.published,
        summary: ep.summary,
        audio: ep.enclosure_url,
        audio_type: ep.enclosure_type,
        audio_size: ep.enclosure_length,
        audio_length: ep.itunes_duration,
        audio_length: ep.itunes_duration
      }
      episodes << episode
    end
    episodes
  end

  def create_podcast(cast_params)
    genres = cast_params[:itunes_genres]
    cast_params.delete(:itunes_genres)
    pod = Podcast.new(cast_params)
    if pod.save
      genres.each do |itunes_id|
        categ = Category.find_by(itunes_id: itunes_id)
        if categ
          PodcastCategory.create(category_id: categ.id, podcast_id: pod.id)
        end
      end
    end
    pod
  end

  def parse_lookup(pod)
    {
      name: pod["collectionName"],
      itunes_id: pod["collectionId"],
      publisher: pod["artistName"],
      itunes_genres: pod["genreIds"],
      image_url: pod["artworkUrl600"],
      sm_image_url: pod["artworkUrl30"],
      md_image_url: pod["artworkUrl100"],
      feed_url: pod["feedUrl"]
    }
  end

  def podcast_params
    params.require(:podcast).permit(:name, :category, :itunes_id, :publisher, :image_url, :sm_image_url, :md_image_url, :feed_url)
  end
end
