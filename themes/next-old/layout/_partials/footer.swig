<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; {% if theme.footer.since and theme.footer.since != current %}{{ theme.footer.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="author" itemprop="copyrightHolder">&nbsp;&nbsp{{ config.author }}</span>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  {{ __('footer.powered', '<a class="theme-link" href="https://hexo.io">Hexo</a>') }}
  &nbsp;&nbsp;|&nbsp;&nbsp;
  {{ __('footer.theme') }} -
  <a class="theme-link" href="https://github.com/iissnan/hexo-theme-next">
    NexT.{{ theme.scheme }}
  </a>
</div>
