'use client';

import BottomBar from '@/components/bottom-bar';
import FullSearchBar from '@/components/full-search-bar';
import Loading from '@/components/loading';
import SideBar from '@/components/side-bar';
import TopBar from '@/components/top-bar';
import { loadingState, viewState } from '@/lib/atoms';
import clsx from 'clsx';
import { useEffect, useState } from 'react';
import { useMediaQuery } from 'react-responsive';
import { useRecoilState, useRecoilValue } from 'recoil';

export default function Layout({ children }: { children: React.ReactNode }) {
  const [view, setView] = useRecoilState(viewState);
  const loading = useRecoilValue(loadingState);
  const [isSideBarShown, setIsSideBarShown] = useState(true);
  const isMobile = useMediaQuery({ maxWidth: 768 });

  useEffect(() => {
    if (isMobile) setView('mobile');
    else setView('pc');
  }, [setView, isMobile]);

  // Wait until detecting appropriate view
  if (view === 'none') return null;

  return (
    <main className={clsx('min-h-screen', view === 'pc' && 'flex')}>
      {/* Left navigation bar (PC) */}
      {view === 'pc' && <SideBar isShown={isSideBarShown} />}

      {/* Page body */}
      <div className={view === 'pc' ? 'flex-1 min-w-0' : ''}>
        {/* Areas fixed at the top of the page */}
        <div
          className={clsx(
            'sticky top-0 bg-white z-10',
            view === 'pc' && 'flex flex-col gap-y-10 pt-4 px-4 pb-8'
          )}
        >
          {/* Hamburger button (PC) or Top bar (Mobile) */}
          {view === 'pc' ? (
            <button
              className="w-6 h-6 text-xl text-charcoal"
              onClick={() => setIsSideBarShown(!isSideBarShown)}
            >
              <i className="fa-solid fa-bars" />
            </button>
          ) : (
            <TopBar />
          )}

          {/* Full search bar */}
          <FullSearchBar />
        </div>

        {/* Page content */}
        <div
          className={clsx(
            'mx-4 overflow-x-auto transition-opacity duration-300 no-scrollbar',
            view === 'pc' ? 'pb-8' : 'pt-4 pb-24',
            loading && 'opacity-30'
          )}
        >
          {children}

          {/* Loading */}
          {loading && (
            <div className="fixed top-2/4 right-2/4 translate-x-2/4 -translate-y-2/4">
              <Loading />
            </div>
          )}
        </div>
      </div>

      {/* Bottom navigation bar (Mobile) */}
      {view === 'mobile' && <BottomBar />}
    </main>
  );
}
