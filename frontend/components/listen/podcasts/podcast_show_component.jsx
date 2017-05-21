import React form 'react';

class PodcastShowComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      constrastColor = "black"
    };
  }

  onPlay(episode) {
    console.log(episode);
  }

  render() {
    pod = this.props.podcast;
    return(
      <section className="podcast-show">
        <div className="episode-viewport">
          <img src={pod.image_url}></img>
          <canvas id="podcast-capture"></canvas>
        </div>
        <div className="episodes">
          <div id="accordion" role="tablist" aria-multiselectable="true">
            {pod.episodes.map((ep, idx) => (
              <EpisodeItemComponent episode={ep} key={"ep-" + ep.idx} onPlay={this.onPlay}/>
            ))}
          </div>
        </div>
      </section>
    );
  }
}